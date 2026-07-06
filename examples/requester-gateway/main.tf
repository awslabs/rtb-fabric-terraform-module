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
}

# Validation resource to provide clear error messages.
# Uses a Terraform-native precondition instead of a local-exec provisioner: the
# error_message is rendered by Terraform and never passed to a shell, so input
# values such as var.cluster_name cannot influence command execution.
resource "null_resource" "discovery_validation" {
  lifecycle {
    precondition {
      condition     = !local.vpc_discovery_failed && !local.subnet_discovery_failed
      error_message = "Auto-discovery failed for cluster ${var.cluster_name}. Please verify: 1) The cluster exists, 2) VPC is tagged with kubernetes.io/cluster/${var.cluster_name}, 3) Subnets are tagged with kubernetes.io/role/internal-elb=1. If auto-discovery cannot be used, consider using a different example with manual network configuration."
    }
  }
}

module "rtb_fabric" {
  source = "../../"

  requester_gateway = {
    create = true
    # Replace hyphens with spaces to comply with GA API schema pattern ^[A-Za-z0-9 ]+$
    description        = "terraform requester gateway for ${replace(var.cluster_name, "-", " ")}"
    vpc_id             = module.cluster_discovery.discovered_vpc_id
    subnet_ids         = module.cluster_discovery.discovered_private_subnet_ids
    security_group_ids = [module.cluster_discovery.discovered_security_group_id]
    tags = {
      Environment = "Prod"
    }
  }
}

# Main gateway outputs
output "gateway_id" {
  description = "The ID of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_id
}

output "gateway_arn" {
  description = "The ARN of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_arn
}

output "gateway_status" {
  description = "The status of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_status
}

output "gateway_domain_name" {
  description = "The domain name of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_domain_name
}

# Configuration transparency outputs
output "configuration_summary" {
  description = "Summary of configuration sources used"
  value = {
    cluster_name_source   = "variable"
    vpc_source            = "auto-discovery"
    subnet_source         = "auto-discovery"
    security_group_source = "auto-discovery"
  }
}

# Discovery outputs for reference
output "discovered_vpc_id" {
  description = "VPC ID discovered from cluster tags"
  value       = module.cluster_discovery.discovered_vpc_id
}

output "discovered_private_subnet_ids" {
  description = "Subnet IDs discovered from cluster tags"
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