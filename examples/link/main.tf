module "rtb_fabric" {
  source = "../../"

  link = {
    create          = true
    gateway_id      = "rtb-gw-d1eyygf3ffpanqmobvww5todt"
    peer_gateway_id = "rtb-gw-6x0lxq8ylrwttalz3zx8ijxda"
    link_attributes = {
      customer_provided_id = "my-custom-id"
      responder_error_masking = [
        {
          http_code                   = "400"
          action                      = "NO_BID"
          logging_types               = ["METRIC", "RESPONSE"]
          response_logging_percentage = 10.5
        }
      ]
    }

    # GA schema logging structure - ApplicationLogs only
    link_log_settings = {
      application_logs = {
        link_application_log_sampling = {
          error_log  = 20
          filter_log = 20
        }
      }
    }

    # Module configuration list is not allowed on link creation. Link must be accepted, then activated before you can attach modules. 
    # do not reuse this resource to create modules if you used http_responder_allowed. Use a separate template as shown in link-modules example
    # we are working to address this issue, however based on the design of RTB Fabric, link creation and module attachment will have to be a two-stage process.

    tags = [
      {
        key   = "Environment"
        value = "Production"
      }
    ]
  }
}

# Link Outputs
output "link_id" {
  description = "ID of the created RTB fabric link"
  value       = module.rtb_fabric.link_id
}

output "link_arn" {
  description = "ARN of the created RTB fabric link"
  value       = module.rtb_fabric.link_arn
}

output "link_status" {
  description = "Status of the created RTB fabric link"
  value       = module.rtb_fabric.link_status
}

output "link_direction" {
  description = "Direction of the created RTB fabric link"
  value       = module.rtb_fabric.link_direction
}

output "link_created_timestamp" {
  description = "Created timestamp of the RTB fabric link"
  value       = module.rtb_fabric.link_created_timestamp
}

output "link_updated_timestamp" {
  description = "Updated timestamp of the RTB fabric link"
  value       = module.rtb_fabric.link_updated_timestamp
}

output "link_full_object" {
  description = "Complete link object returned by Cloud Control API"
  value       = module.rtb_fabric.link_full_object
}

