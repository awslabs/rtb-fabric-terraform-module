# Variables are defined in variables.tf


# Use shared EKS cluster discovery logic
module "cluster_discovery" {
  source       = "../common"
  cluster_name = var.cluster_name
}

# Validate auto-discovery results
locals {
  vpc_discovery_failed    = length(module.cluster_discovery.discovered_vpc_id) == 0
  subnet_discovery_failed = length(module.cluster_discovery.discovered_private_subnet_ids) == 0

  discovery_error_message = local.vpc_discovery_failed || local.subnet_discovery_failed ? "Auto-discovery failed for cluster '${var.cluster_name}'. Please verify: 1) The cluster exists, 2) VPC is tagged with 'kubernetes.io/cluster/${var.cluster_name}', 3) Subnets are tagged with 'kubernetes.io/role/internal-elb=1'. If auto-discovery cannot be used, consider using a different example with manual network configuration." : ""
}

# Validation resource to provide clear error messages
resource "null_resource" "discovery_validation" {
  count = (local.vpc_discovery_failed || local.subnet_discovery_failed) ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ERROR: ${local.discovery_error_message}' && exit 1"
  }
}

module "rtb_fabric" {
  source = "../../"

  # Optional: Customize the EKS Discovery Role name for enterprise naming conventions
  # rtbfabric_eks_discovery_role_name = "MyCompany-RTBFabric-EKS-Discovery-Role"

  providers = {
    kubernetes = kubernetes.responder
  }
  responder_gateway = {
    create = true
    # Replace hyphens with spaces to comply with GA API schema pattern ^[A-Za-z0-9 ]+$
    description        = "terraform responder gateway for ${replace(var.cluster_name, "-", " ")}"
    vpc_id             = module.cluster_discovery.discovered_vpc_id
    subnet_ids         = module.cluster_discovery.discovered_private_subnet_ids
    security_group_ids = [module.cluster_discovery.discovered_security_group_id]
    port               = 8090
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder-internal"
        endpoints_resource_namespace = "default"
        cluster_name                 = var.cluster_name
        # eks_service_discovery_role not specified - will create default role automatically
        # cluster_access_role_arn if not specified - will use current Terraform credentials
        auto_create_role   = true
        auto_create_access = true
        auto_create_rbac   = true

        # cluster_api_server_endpoint_uri automatically retrieved
        # cluster_api_server_ca_certificate_chain automatically retrieved
      }
    }

    tags = {
      Environment = "Test"
      EKSCluster  = var.cluster_name
    }
  }
}

# Main gateway outputs
output "gateway_id" {
  description = "The ID of the responder gateway"
  value       = module.rtb_fabric.responder_gateway_id
}

output "gateway_arn" {
  description = "The ARN of the responder gateway"
  value       = module.rtb_fabric.responder_gateway_arn
}

output "gateway_status" {
  description = "The status of the responder gateway"
  value       = module.rtb_fabric.responder_gateway_status
}

output "gateway_domain_name" {
  description = "The domain name of the responder gateway"
  value       = module.rtb_fabric.responder_gateway_domain_name
}

# Configuration transparency outputs
output "configuration_summary" {
  description = "Summary of configuration sources used"
  value = {
    cluster_name_source   = "variable"
    vpc_source            = "auto-discovery"
    subnet_source         = "auto-discovery"
    security_group_source = "auto-discovery"
    authentication_source = var.kubernetes_auth_role_name != null ? "role-based" : "current-credentials"
  }
}

# Discovery outputs for reference
output "discovered_vpc_id" {
  description = "VPC ID discovered from cluster tags"
  value       = module.cluster_discovery.discovered_vpc_id
}

output "discovered_private_subnet_ids" {
  description = "Private subnet IDs discovered from cluster tags"
  value       = module.cluster_discovery.discovered_private_subnet_ids
}

output "discovered_security_group_id" {
  description = "Security group ID from EKS cluster"
  value       = module.cluster_discovery.discovered_security_group_id
}

# Final values used
output "used_values" {
  description = "Final configuration values used in deployment"
  value = {
    cluster_name       = var.cluster_name
    vpc_id             = module.cluster_discovery.discovered_vpc_id
    subnet_ids         = module.cluster_discovery.discovered_private_subnet_ids
    security_group_ids = [module.cluster_discovery.discovered_security_group_id]
  }
}
