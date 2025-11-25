# RTB Fabric Link using awscc provider
resource "awscc_rtbfabric_link" "link" {
  count = var.link.create ? 1 : 0

  # Required attributes
  gateway_id      = var.link.gateway_id
  peer_gateway_id = var.link.peer_gateway_id

  link_log_settings = {
    application_logs = {
      link_application_log_sampling = {
        error_log  = var.link.link_log_settings != null ? var.link.link_log_settings.application_logs.link_application_log_sampling.error_log : 0
        filter_log = var.link.link_log_settings != null ? var.link.link_log_settings.application_logs.link_application_log_sampling.filter_log : 0
      }
    }
  }

  # Optional attributes - pass through directly
  # http_responder_allowed: Only set on initial creation to avoid update failures
  # Cloud Control API doesn't return this field, causing state drift
  # After creation, this will be null in config but ignored by lifecycle rule
  http_responder_allowed    = try(var.link.http_responder_allowed, null)
  link_attributes           = var.link.link_attributes
  module_configuration_list = var.link.module_configuration_list
  tags                      = var.link.tags

  # AWS only allows updating tags and link_log_settings after creation
  # All other fields are immutable and require replacement
  lifecycle {
    create_before_destroy = true
    # Ignore changes to immutable fields to prevent update failures
    ignore_changes = [
      gateway_id,
      peer_gateway_id,
      http_responder_allowed,
      link_attributes
    ]
  }
}


