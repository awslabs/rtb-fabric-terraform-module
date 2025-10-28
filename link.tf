resource "aws_cloudcontrolapi_resource" "link" {
  count = var.link.create ? 1 : 0

  type_name = "AWS::RTBFabric::Link"

  desired_state = jsonencode(merge(
    {
      # Required fields - must not be null
      GatewayId     = var.link.gateway_id
      PeerGatewayId = var.link.peer_gateway_id
      # LinkLogSettings is required in GA schema
      LinkLogSettings = var.link.link_log_settings != null ? {
        ApplicationLogs = {
          LinkApplicationLogSampling = {
            ErrorLog  = var.link.link_log_settings.service_logs != null ? var.link.link_log_settings.service_logs.link_service_log_sampling.error_log : 0
            FilterLog = var.link.link_log_settings.service_logs != null ? var.link.link_log_settings.service_logs.link_service_log_sampling.filter_log : 0
          }
        }
      } : {
        ApplicationLogs = {
          LinkApplicationLogSampling = {
            ErrorLog  = 0
            FilterLog = 0
          }
        }
      }
      Tags = var.link.tags != null ? [for tag in var.link.tags : {
        Key   = tag.key
        Value = tag.value
      }] : []
    },
    # HttpResponderAllowed (write-only in GA schema)
    var.link.http_responder_allowed != null ? { HttpResponderAllowed = var.link.http_responder_allowed } : {},
    # LinkAttributes
    var.link.link_attributes != null ? {
      LinkAttributes = merge(
        var.link.link_attributes.customer_provided_id != null ? { CustomerProvidedId = var.link.link_attributes.customer_provided_id } : {},
        var.link.link_attributes.responder_error_masking != null ? {
          ResponderErrorMasking = [for mask in var.link.link_attributes.responder_error_masking : {
            HttpCode                  = mask.http_code
            Action                    = mask.action
            LoggingTypes              = mask.logging_types
            ResponseLoggingPercentage = mask.response_logging_percentage
          }]
        } : {}
      )
    } : {},
    # Support for new ModuleConfigurationList
    var.link.module_configuration_list != null ? { ModuleConfigurationList = var.link.module_configuration_list } : {}
  ))
}