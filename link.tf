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
            ErrorLog  = var.link.link_log_settings.application_logs.link_application_log_sampling.error_log
            FilterLog = var.link.link_log_settings.application_logs.link_application_log_sampling.filter_log
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
    # Support for new ModuleConfigurationList with GA schema structure
    var.link.module_configuration_list != null ? {
      ModuleConfigurationList = [for module in var.link.module_configuration_list : merge(
        {
          Name = module.name
        },
        module.version != null ? { Version = module.version } : {},
        module.depends_on != null ? { DependsOn = module.depends_on } : {},
        # Build ModuleParameters based on module_type (oneOf constraint)
        # Only include ModuleParameters if we have valid parameters for the specified type
        module.module_type == "NoBid" && module.no_bid_parameters != null ? {
          ModuleParameters = {
            NoBid = merge(
              module.no_bid_parameters.reason != null ? { Reason = module.no_bid_parameters.reason } : {},
              module.no_bid_parameters.reason_code != null ? { ReasonCode = module.no_bid_parameters.reason_code } : {},
              module.no_bid_parameters.pass_through_percentage != null ? { PassThroughPercentage = module.no_bid_parameters.pass_through_percentage } : {}
            )
          }
          } : module.module_type == "OpenRtbAttribute" && module.open_rtb_attribute_parameters != null ? {
          ModuleParameters = {
            OpenRtbAttribute = merge(
              {
                FilterType = module.open_rtb_attribute_parameters.filter_type
                FilterConfiguration = [for filter in module.open_rtb_attribute_parameters.filter_configuration : {
                  Criteria = [for criterion in filter.criteria : {
                    Path   = criterion.path
                    Values = criterion.values
                  }]
                }]
                HoldbackPercentage = module.open_rtb_attribute_parameters.holdback_percentage
              },
              # Only include Action if we have valid action parameters
              module.open_rtb_attribute_parameters.action_type == "NoBid" && module.open_rtb_attribute_parameters.no_bid_action != null ? {
                Action = {
                  NoBid = merge(
                    module.open_rtb_attribute_parameters.no_bid_action.no_bid_reason_code != null ? { NoBidReasonCode = module.open_rtb_attribute_parameters.no_bid_action.no_bid_reason_code } : {}
                  )
                }
                } : module.open_rtb_attribute_parameters.action_type == "HeaderTag" && module.open_rtb_attribute_parameters.header_tag_action != null ? {
                Action = {
                  HeaderTag = {
                    Name  = module.open_rtb_attribute_parameters.header_tag_action.name
                    Value = module.open_rtb_attribute_parameters.header_tag_action.value
                  }
                }
              } : {}
            )
          }
        } : {}
      )]
    } : {}
  ))
}
