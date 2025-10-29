module "rtb_fabric" {
  source = "../../"

  link = {
    create                 = true
    gateway_id             = "rtb-gw-8ju4h75ashssqk806puaj2dow"
    peer_gateway_id        = "rtb-gw-8x61nhczimggnzwcaqssma1w5"
    http_responder_allowed = true

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

    # GA schema ModuleConfigurationList - using discriminated union approach
    module_configuration_list = [
      {
        name        = "NoBidModule"
        version     = "v1"
        module_type = "NoBid"
        no_bid_parameters = {
          reason                  = "TestReason"
          reason_code             = 1
          pass_through_percentage = 10.0
        }
      }
    ]

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
