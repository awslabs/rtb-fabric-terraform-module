resource "aws_cloudcontrolapi_resource" "link" {
  count = var.link.create ? 1 : 0

  type_name = "AWS::RTBFabric::Link"

  desired_state = jsonencode(merge(
    {
      RtbAppId     = var.link.rtb_app_id
      PeerRtbAppId = var.link.peer_rtb_app_id
      Tags = [for tag in var.link.tags : {
        Key   = tag.key
        Value = tag.value
      }]
    },
    var.link.http_responder_allowed != null ? { HttpResponderAllowed = var.link.http_responder_allowed } : {},
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
    var.link.link_log_settings != null ? {
      LinkLogSettings = merge(
        var.link.link_log_settings.service_logs != null ? {
          ServiceLogs = {
            LinkServiceLogSampling = {
              ErrorLog  = var.link.link_log_settings.service_logs.link_service_log_sampling.error_log
              FilterLog = var.link.link_log_settings.service_logs.link_service_log_sampling.filter_log
            }
          }
        } : {},
        var.link.link_log_settings.analytics_logs != null ? {
          AnalyticsLogs = {
            LinkAnalyticsLogSampling = {
              BidLog = var.link.link_log_settings.analytics_logs.link_analytics_log_sampling.bid_log
            }
          }
        } : {}
      )
    } : {}
  ))
}