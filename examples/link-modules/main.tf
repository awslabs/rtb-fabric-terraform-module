# RTB Fabric Link Modules Management Example
# 
# This example shows how to add module configuration to an existing link
# after it has been accepted by the peer.
#
# IMPORTANT: Links must be accepted by the peer before modules can be attached.
# There is no Terraform or CloudFormation support to accept links - this must
# be done manually through the AWS Console or CLI by the peer account.

# Import the existing link that was created and accepted
import {
  to = module.rtb_fabric.awscc_rtbfabric_link.link[0]
  id = "arn:aws:rtbfabric:us-east-1:<ACCOUNT_ID>:gateway/<GATEWAY_ID>/link/<LINK_ID>" # Replace with your link ARN
}

module "rtb_fabric" {
  source = "../../"

  # Import existing link and add module configuration
  link = {
    create          = true
    gateway_id      = "rtb-gw-6x0lxq8ylrwttalz3zx8ijxda" # Replace with peer gateway ID
    peer_gateway_id = "rtb-gw-d1eyygf3ffpanqmobvww5todt" # Replace with your gateway ID

    # # Link log settings (required)
    link_log_settings = {
      application_logs = {
        link_application_log_sampling = {
          error_log  = 20
          filter_log = 20
        }
      }
    }

    # Module configuration - add after link is accepted
    module_configuration_list = [
      # NoBid Module Example
      {
        name    = "NoBidModule"
        version = "v1"
        module_parameters = {
          no_bid = {
            reason                  = "TestReason"
            reason_code             = 1
            pass_through_percentage = 10.0
          }
        }
      },
      # OpenRTB Filter Module Example
      {
        name    = "OpenRtbFilter"
        version = "v1"
        module_parameters = {
          open_rtb_attribute = {
            filter_type = "INCLUDE"
            filter_configuration = [
              {
                criteria = [
                  {
                    path   = "$.openrtb.request.context.site.domain"
                    values = ["example.com", "example.org"]
                  }
                ]
              }
            ]
            action = {
              no_bid = {
                no_bid_reason_code = 3
              }
            }
            holdback_percentage = 5.0
          }
        }
      }
    ]

    tags = {
      Environment = "Production"
      ManagedBy   = "Terraform"
    }
  }
}

# Outputs
output "link_id" {
  description = "ID of the link"
  value       = module.rtb_fabric.link_id
}

output "link_arn" {
  description = "ARN of the link"
  value       = module.rtb_fabric.link_arn
}

output "link_status" {
  description = "Status of the link"
  value       = module.rtb_fabric.link_status
}


