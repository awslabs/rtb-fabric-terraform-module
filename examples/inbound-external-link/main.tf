module "rtb_fabric" {
  source = "../../"

  inbound_external_link = {
    create     = true
    gateway_id = var.gateway_id

    link_log_settings = {
      error_log  = 10
      filter_log = 5
    }

    link_attributes = {
      customer_provided_id = var.customer_provided_id

      responder_error_masking = [
        {
          http_code                   = "400"
          action                      = "NO_BID"
          logging_types               = ["METRIC", "RESPONSE"]
          response_logging_percentage = 15.0
        },
        {
          http_code                   = "500"
          action                      = "NO_BID"
          logging_types               = ["METRIC"]
          response_logging_percentage = 25.0
        }
      ]
    }

    tags = {
      Environment = "Production"
      LinkType    = "External"
      ManagedBy   = "Terraform"
    }
  }
}

# Outputs
output "link_id" {
  description = "Link ID of the created inbound external link"
  value       = module.rtb_fabric.inbound_external_link_id
}

output "link_arn" {
  description = "ARN of the created inbound external link"
  value       = module.rtb_fabric.inbound_external_link_arn
}

output "link_status" {
  description = "Status of the created inbound external link"
  value       = module.rtb_fabric.inbound_external_link_status
}

output "gateway_id" {
  description = "Gateway ID that the link is attached to"
  value       = module.rtb_fabric.inbound_external_link_gateway_id
}

output "created_timestamp" {
  description = "Creation timestamp"
  value       = module.rtb_fabric.inbound_external_link_created_timestamp
}

output "updated_timestamp" {
  description = "Last update timestamp"
  value       = module.rtb_fabric.inbound_external_link_updated_timestamp
}
