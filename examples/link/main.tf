module "rtb_fabric" {
  source = "../../"

  link = {
    create                 = true
    gateway_id             = "rtb-gw-abc123"
    peer_gateway_id        = "rtb-gw-def456"
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

    # Updated logging structure for GA schema
    link_log_settings = {
      service_logs = {
        link_service_log_sampling = {
          error_log  = 100
          filter_log = 50
        }
      }
      # analytics_logs removed in GA schema - only application_logs supported
    }

    # Example of new ModuleConfigurationList feature
    module_configuration_list = [
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