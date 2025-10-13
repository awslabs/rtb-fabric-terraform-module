module "rtb_fabric" {
  source = "../../"

  link = {
    create                 = true
    rtb_app_id             = "rtbapp-abc123"
    peer_rtb_app_id        = "rtbapp-def456"
    http_responder_allowed = true

    link_attributes = {
      customer_provided_id = "my-custom-id"
      responder_error_masking = [
        {
          http_code                   = "4XX"
          action                      = "NO_BID"
          logging_types               = ["METRIC", "RESPONSE"]
          response_logging_percentage = 10.5
        }
      ]
    }

    link_log_settings = {
      service_logs = {
        link_service_log_sampling = {
          error_log  = 100
          filter_log = 50
        }
      }
      analytics_logs = {
        link_analytics_log_sampling = {
          bid_log = 25
        }
      }
    }

    tags = [
      {
        key   = "Environment"
        value = "Production"
      }
    ]
  }
}