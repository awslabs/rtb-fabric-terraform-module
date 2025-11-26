# Variables are defined in variables.tf

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

# Validate auto-discovery results for both clusters
locals {
  requester_vpc_discovery_failed    = length(module.requester_cluster_discovery.discovered_vpc_id) == 0
  requester_subnet_discovery_failed = length(module.requester_cluster_discovery.discovered_private_subnet_ids) == 0
  responder_vpc_discovery_failed    = length(module.responder_cluster_discovery.discovered_vpc_id) == 0
  responder_subnet_discovery_failed = length(module.responder_cluster_discovery.discovered_private_subnet_ids) == 0

  discovery_failed = local.requester_vpc_discovery_failed || local.requester_subnet_discovery_failed || local.responder_vpc_discovery_failed || local.responder_subnet_discovery_failed

  discovery_error_message = local.discovery_failed ? "Auto-discovery failed for one or more clusters. Please verify: 1) Clusters '${var.requester_cluster_name}' and '${var.responder_cluster_name}' exist, 2) VPCs are tagged with 'kubernetes.io/cluster/<cluster_name>', 3) Subnets are tagged with 'kubernetes.io/role/internal-elb=1'." : ""
}

# Validation resource to provide clear error messages
resource "null_resource" "discovery_validation" {
  count = local.discovery_failed ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ERROR: ${local.discovery_error_message}' && exit 1"
  }
}

# Single module instance for complete E2E test: Requester + EKS Responder + Link
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module?ref=v0.3.0"

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
    tags = {
      Environment = "E2ETest"
      EKSCluster  = var.requester_cluster_name
      NewTagTest  = "true"
    }
  }

  providers = {
    kubernetes = kubernetes.responder
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
        auto_create_access         = true
        auto_create_rbac           = true
        # cluster_api_server_endpoint_uri automatically retrieved
        # cluster_api_server_ca_certificate_chain automatically retrieved
      }
    }

    tags = {
      Environment = "E2ETest"
      EKSCluster  = var.responder_cluster_name
    }
  }
}

# Separate module for the link to use gateway IDs from the first module
module "rtb_fabric_link" {
  source = "github.com/awslabs/rtb-fabric-terraform-module?ref=v0.3.0"

  # Link between Requester and EKS Responder
  link = {
    create          = true
    gateway_id      = module.rtb_fabric.requester_gateway_id
    peer_gateway_id = module.rtb_fabric.responder_gateway_id

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

    tags = {
      link-key : "linkvalue"
    }

    # GA schema ModuleConfigurationList - matches AWS schema directly
    #  module_configuration_list - attribute not allowed for link creation. Only applies to links that were accepted first and active. 
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
  sensitive   = true
}

output "link_arn" {
  description = "ARN of the created RTB fabric link"
  value       = module.rtb_fabric_link.link_arn
  sensitive   = true
}

output "link_status" {
  description = "Status of the created RTB fabric link"
  value       = module.rtb_fabric_link.link_status
  sensitive   = true
}

output "link_direction" {
  description = "Direction of the created RTB fabric link"
  value       = module.rtb_fabric_link.link_direction
  sensitive   = true
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

# Configuration transparency outputs
output "configuration_summary" {
  description = "Summary of configuration sources used"
  value = {
    requester_cluster_name_source   = "variable"
    responder_cluster_name_source   = "variable"
    requester_vpc_source            = "auto-discovery"
    requester_subnet_source         = "auto-discovery"
    requester_security_group_source = "auto-discovery"
    responder_vpc_source            = "auto-discovery"
    responder_subnet_source         = "auto-discovery"
    responder_security_group_source = "auto-discovery"
    authentication_source           = var.kubernetes_auth_role_name != null ? "role-based" : "current-credentials"
  }
}

# Final values used
output "used_values" {
  description = "Final configuration values used in deployment"
  value = {
    requester_cluster_name       = var.requester_cluster_name
    responder_cluster_name       = var.responder_cluster_name
    requester_vpc_id             = module.requester_cluster_discovery.discovered_vpc_id
    requester_subnet_ids         = module.requester_cluster_discovery.discovered_private_subnet_ids
    requester_security_group_ids = [module.requester_cluster_discovery.discovered_security_group_id]
    responder_vpc_id             = module.responder_cluster_discovery.discovered_vpc_id
    responder_subnet_ids         = module.responder_cluster_discovery.discovered_private_subnet_ids
    responder_security_group_ids = [module.responder_cluster_discovery.discovered_security_group_id]
  }
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
