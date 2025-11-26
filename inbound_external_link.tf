# RTB Fabric Inbound External Link using awscc provider
resource "awscc_rtbfabric_inbound_external_link" "inbound_external_link" {
  count = var.inbound_external_link.create ? 1 : 0

  # Required attributes
  gateway_id = var.inbound_external_link.gateway_id

  link_log_settings = {
    application_logs = {
      link_application_log_sampling = {
        error_log  = var.inbound_external_link.link_log_settings != null ? var.inbound_external_link.link_log_settings.error_log : 0
        filter_log = var.inbound_external_link.link_log_settings != null ? var.inbound_external_link.link_log_settings.filter_log : 0
      }
    }
  }

  # Optional attributes
  link_attributes = var.inbound_external_link.link_attributes
  tags            = local.inbound_external_link_tags

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
  }
}
