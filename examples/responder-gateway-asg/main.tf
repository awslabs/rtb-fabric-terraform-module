# RTB Fabric ASG Managed Endpoint Example
# This example demonstrates automatic ASG discovery role creation
# The module will create RTBFabricAsgDiscoveryRole with proper trust policy and permissions

module "rtb_fabric" {
  source = "../../"

  # Optional: Customize the ASG Discovery Role name for enterprise naming conventions
  # rtbfabric_asg_discovery_role_name = "MyCompany-RTBFabric-ASG-Discovery-Role"

  responder_gateway = {
    create             = true
    description        = "terraform responder gateway asg test"
    vpc_id             = var.vpc_id
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
    port               = 31234
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      auto_scaling_groups_configuration = {
        auto_scaling_group_name_list = var.auto_scaling_group_names
        # asg_discovery_role = null  # Uses default RTBFabricAsgDiscoveryRole
        # auto_create_role = true    # Automatically creates the role (default)
      }
    }

    tags = [
      {
        key   = "Environment"
        value = "Test"
      }
    ]
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
    vpc_source            = "manual"
    subnet_source         = "manual"
    security_group_source = "manual"
    asg_source            = "manual"
  }
}

# Final values used
output "used_values" {
  description = "Final configuration values used in deployment"
  value = {
    vpc_id                   = var.vpc_id
    subnet_ids               = var.subnet_ids
    security_group_ids       = var.security_group_ids
    auto_scaling_group_names = var.auto_scaling_group_names
  }
}