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
    vpc_id             = "vpc-01a185e1a42ffbb7b"
    subnet_ids         = ["subnet-05f406bce380d07e8"]
    security_group_ids = ["sg-0a79869648d9b8540"]
    port               = 31234
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      auto_scaling_groups_configuration = {
        auto_scaling_group_name_list = ["eks-EksNodegroupApplication-J3fkHClrMvmz-0ecac562-c566-3f37-20f9-0145a26266a9"]
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

