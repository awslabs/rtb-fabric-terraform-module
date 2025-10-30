module "rtb_fabric" {
  source = "../../"

  responder_gateway = {
    create             = true
    description        = "terraform responder gateway basic test"
    vpc_id             = var.vpc_id
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
    port               = 31234
    protocol           = "HTTP"
    domain_name        = var.domain_name
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
    vpc_source = "manual"
    subnet_source = "manual"
    security_group_source = "manual"
    domain_name_source = "manual"
  }
}

# Final values used
output "used_values" {
  description = "Final configuration values used in deployment"
  value = {
    vpc_id = var.vpc_id
    subnet_ids = var.subnet_ids
    security_group_ids = var.security_group_ids
    domain_name = var.domain_name
  }
}