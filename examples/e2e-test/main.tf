# Variables for cluster names - customers provide these
variable "requester_cluster_name" {
  description = "Name of the EKS cluster for the requester gateway"
  type        = string
  default     = "publisher-eks"
}

variable "responder_cluster_name" {
  description = "Name of the EKS cluster for the responder gateway"
  type        = string
  default     = "rtbkit-shapirov-iad"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Cluster discovery for requester gateway
module "requester_cluster_discovery" {
  source       = "../common"
  cluster_name = var.requester_cluster_name
}

# Cluster discovery for responder gateway
module "responder_cluster_discovery" {
  source       = "../common"
  cluster_name = var.responder_cluster_name
}

# Single module instance for complete E2E test: Requester + EKS Responder + Link
module "rtb_fabric" {
  source = "../../"

  # Optional: Customize the EKS Discovery Role name for enterprise naming conventions
  # rtbfabric_eks_discovery_role_name = "MyCompany-RTBFabric-EKS-Discovery-Role"

  # Note: This example demonstrates auto_create_role functionality:
  # - When auto_create_role = true (default): Creates the specified role name
  # - When auto_create_role = false: Assumes the role already exists
  # - When eks_service_discovery_role is null: Uses default role name and creates it

  # Requester Gateway
  requester_gateway = {
    create = true
    # Replace hyphens with spaces to comply with GA API schema pattern ^[A-Za-z0-9 ]+$
    description        = "E2E test requester gateway for ${replace(var.requester_cluster_name, "-", " ")}"
    vpc_id             = module.requester_cluster_discovery.discovered_vpc_id
    subnet_ids         = module.requester_cluster_discovery.discovered_private_subnet_ids
    security_group_ids = [module.requester_cluster_discovery.discovered_security_group_id]
    tags = [
      {
        key   = "Environment"
        value = "E2ETest"
      },
      {
        key   = "EKSCluster"
        value = var.requester_cluster_name
      }
    ]
  }

  providers = {
    kubernetes =  kubernetes.responder
  }
  # EKS Responder Gateway
  responder_gateway = {
    create = true
    # Replace hyphens with spaces to comply with GA API schema pattern ^[A-Za-z0-9 ]+$
    description        = "E2E test EKS responder gateway for ${replace(var.responder_cluster_name, "-", " ")}"
    vpc_id             = module.responder_cluster_discovery.discovered_vpc_id
    subnet_ids         = module.responder_cluster_discovery.discovered_private_subnet_ids
    security_group_ids = [module.responder_cluster_discovery.discovered_security_group_id]
    port               = 8090
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder-internal"
        endpoints_resource_namespace = "default"
        cluster_name                 = var.responder_cluster_name
        # Custom role name with auto-creation enabled to avoid conflicts
        eks_service_discovery_role = "E2ETest-${var.responder_cluster_name}-EKSDiscoveryRole"
        auto_create_role           = true
        # cluster_access_role_arn if not specified - will use current Terraform credentials
        cluster_access_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/rtbkit-shapirov-iad-EksAccessRole-CA7FhiO8nskv"
        auto_create_access      = true
        auto_create_rbac        = true
        # cluster_api_server_endpoint_uri automatically retrieved
        # cluster_api_server_ca_certificate_chain automatically retrieved
      }
    }

    tags = [
      {
        key   = "Environment"
        value = "E2ETest"
      },
      {
        key   = "EKSCluster"
        value = var.responder_cluster_name
      }
    ]
  }

}

# Separate module for the link to use gateway IDs from the first module
module "rtb_fabric_link" {
  source = "../../"

  # Link between Requester and EKS Responder
  link = {
    create                 = true
    gateway_id             = module.rtb_fabric.requester_gateway_id
    peer_gateway_id        = module.rtb_fabric.responder_gateway_id
    http_responder_allowed = true

    link_attributes = {
      customer_provided_id = "e2e-test-link"
      responder_error_masking = [
        {
          http_code                   = "400"
          action                      = "NO_BID"
          logging_types               = ["METRIC", "RESPONSE"]
          response_logging_percentage = 15.0
        }
      ]
    }

    # GA schema logging structure - ApplicationLogs only
    link_log_settings = {
      application_logs = {
        link_application_log_sampling = {
          error_log  = 25
          filter_log = 15
        }
      }
    }

    # GA schema ModuleConfigurationList - using discriminated union approach
    module_configuration_list = [
      {
        name        = "E2ETestNoBidModule"
        version     = "v1"
        module_type = "NoBid"
        no_bid_parameters = {
          reason                  = "E2ETestReason"
          reason_code             = 2
          pass_through_percentage = 5.0
        }
      },
      {
        name        = "E2ETestOpenRtbModule"
        version     = "v1"
        module_type = "OpenRtbAttribute"
        open_rtb_attribute_parameters = {
          filter_type = "EXCLUDE"
          filter_configuration = [
            {
              criteria = [
                {
                  path   = "imp[0].banner.h"
                  values = ["250", "600"]
                }
              ]
            }
          ]
          action_type = "HeaderTag"
          header_tag_action = {
            name  = "X-E2E-Test"
            value = "banner-height-filtered"
          }
          holdback_percentage = 10.0
        }
      }
    ]

    tags = [
      {
        key   = "Environment"
        value = "E2ETest"
      },
      {
        key   = "RequesterCluster"
        value = var.requester_cluster_name
      },
      {
        key   = "ResponderCluster"
        value = var.responder_cluster_name
      }
    ]
  }
}

# Requester Gateway Outputs
output "requester_gateway_id" {
  description = "The ID of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_id
}

output "requester_gateway_arn" {
  description = "The ARN of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_arn
}

output "requester_gateway_status" {
  description = "The status of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_status
}

output "requester_gateway_domain_name" {
  description = "The domain name of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_domain_name
}

# Responder Gateway Outputs
output "responder_gateway_id" {
  description = "The ID of the EKS responder gateway"
  value       = module.rtb_fabric.responder_gateway_id
}

output "responder_gateway_arn" {
  description = "The ARN of the EKS responder gateway"
  value       = module.rtb_fabric.responder_gateway_arn
}

output "responder_gateway_status" {
  description = "The status of the EKS responder gateway"
  value       = module.rtb_fabric.responder_gateway_status
}

output "responder_gateway_domain_name" {
  description = "The domain name of the EKS responder gateway"
  value       = module.rtb_fabric.responder_gateway_domain_name
}

# Link Outputs
output "link_id" {
  description = "ID of the created RTB fabric link"
  value       = module.rtb_fabric_link.link_id
}

output "link_arn" {
  description = "ARN of the created RTB fabric link"
  value       = module.rtb_fabric_link.link_arn
}

output "link_status" {
  description = "Status of the created RTB fabric link"
  value       = module.rtb_fabric_link.link_status
}

output "link_direction" {
  description = "Direction of the created RTB fabric link"
  value       = module.rtb_fabric_link.link_direction
}

# Requester Cluster Discovery Outputs
output "requester_discovered_vpc_id" {
  description = "VPC ID discovered from requester cluster tags"
  value       = module.requester_cluster_discovery.discovered_vpc_id
}

output "requester_discovered_private_subnet_ids" {
  description = "Private subnet IDs discovered from requester cluster tags"
  value       = module.requester_cluster_discovery.discovered_private_subnet_ids
}

output "requester_discovered_security_group_id" {
  description = "Security group ID from requester EKS cluster"
  value       = module.requester_cluster_discovery.discovered_security_group_id
}

# Responder Cluster Discovery Outputs
output "responder_discovered_vpc_id" {
  description = "VPC ID discovered from responder cluster tags"
  value       = module.responder_cluster_discovery.discovered_vpc_id
}

output "responder_discovered_private_subnet_ids" {
  description = "Private subnet IDs discovered from responder cluster tags"
  value       = module.responder_cluster_discovery.discovered_private_subnet_ids
}

output "responder_discovered_security_group_id" {
  description = "Security group ID from responder EKS cluster"
  value       = module.responder_cluster_discovery.discovered_security_group_id
}

# EKS Service Discovery Role Output
output "eks_service_discovery_role_arn" {
  description = "ARN of the EKS Service Discovery Role (auto-created or provided)"
  value       = module.rtb_fabric.eks_service_discovery_role_arn
}

output "eks_service_discovery_role_name" {
  description = "Name of the EKS Service Discovery Role (auto-created or provided)"
  value       = module.rtb_fabric.eks_service_discovery_role_name
}
