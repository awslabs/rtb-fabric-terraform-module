# Requester Gateway Outputs
output "requester_gateway_id" {
  description = "ID of the created requester RTB gateway"
  value       = var.requester_gateway.create ? awscc_rtbfabric_requester_gateway.requester_gateway[0].gateway_id : null
}

output "requester_gateway_arn" {
  description = "ARN of the created requester RTB gateway"
  value       = var.requester_gateway.create ? awscc_rtbfabric_requester_gateway.requester_gateway[0].arn : null
}

output "requester_gateway_domain_name" {
  description = "Domain name of the created requester RTB gateway"
  value       = var.requester_gateway.create ? awscc_rtbfabric_requester_gateway.requester_gateway[0].domain_name : null
}

output "requester_gateway_status" {
  description = "Status of the created requester RTB gateway"
  value       = var.requester_gateway.create ? awscc_rtbfabric_requester_gateway.requester_gateway[0].requester_gateway_status : null
}

output "requester_active_links_count" {
  description = "Number of active links for the requester gateway"
  value       = var.requester_gateway.create ? awscc_rtbfabric_requester_gateway.requester_gateway[0].active_links_count : null
}

output "requester_total_links_count" {
  description = "Total number of links for the requester gateway"
  value       = var.requester_gateway.create ? awscc_rtbfabric_requester_gateway.requester_gateway[0].total_links_count : null
}

output "requester_gateway_created_timestamp" {
  description = "Creation timestamp of the requester gateway"
  value       = var.requester_gateway.create ? awscc_rtbfabric_requester_gateway.requester_gateway[0].created_timestamp : null
}

output "requester_gateway_updated_timestamp" {
  description = "Last update timestamp of the requester gateway"
  value       = var.requester_gateway.create ? awscc_rtbfabric_requester_gateway.requester_gateway[0].updated_timestamp : null
}

# Responder Gateway Outputs
output "responder_gateway_id" {
  description = "ID of the created responder RTB gateway"
  value       = var.responder_gateway.create ? awscc_rtbfabric_responder_gateway.responder_gateway[0].gateway_id : null
}

output "responder_gateway_arn" {
  description = "ARN of the created responder RTB gateway"
  value       = var.responder_gateway.create ? awscc_rtbfabric_responder_gateway.responder_gateway[0].arn : null
}

output "responder_gateway_domain_name" {
  description = "Domain name of the created responder RTB gateway (read-only)"
  value       = var.responder_gateway.create ? awscc_rtbfabric_responder_gateway.responder_gateway[0].domain_name : null
}

output "responder_gateway_status" {
  description = "Status of the created responder RTB gateway"
  value       = var.responder_gateway.create ? awscc_rtbfabric_responder_gateway.responder_gateway[0].responder_gateway_status : null
}

output "responder_gateway_created_timestamp" {
  description = "Creation timestamp of the responder gateway"
  value       = var.responder_gateway.create ? awscc_rtbfabric_responder_gateway.responder_gateway[0].created_timestamp : null
}

output "responder_gateway_updated_timestamp" {
  description = "Last update timestamp of the responder gateway"
  value       = var.responder_gateway.create ? awscc_rtbfabric_responder_gateway.responder_gateway[0].updated_timestamp : null
}

# Link Outputs
output "link_id" {
  description = "ID of the created RTB fabric link"
  value       = var.link.create ? awscc_rtbfabric_link.link[0].link_id : null
}

output "link_arn" {
  description = "ARN of the created RTB fabric link"
  value       = var.link.create ? awscc_rtbfabric_link.link[0].arn : null
}

output "link_status" {
  description = "Status of the created RTB fabric link"
  value       = var.link.create ? awscc_rtbfabric_link.link[0].link_status : null
}

output "link_direction" {
  description = "Direction of the created RTB fabric link"
  value       = var.link.create ? awscc_rtbfabric_link.link[0].link_direction : null
}

output "link_created_timestamp" {
  description = "Created timestamp of the RTB fabric link"
  value       = var.link.create ? awscc_rtbfabric_link.link[0].created_timestamp : null
}

output "link_updated_timestamp" {
  description = "Updated timestamp of the RTB fabric link"
  value       = var.link.create ? awscc_rtbfabric_link.link[0].updated_timestamp : null
}

# Legacy output names for backward compatibility
output "link_state" {
  description = "State of the created RTB fabric link (legacy name)"
  value       = var.link.create ? awscc_rtbfabric_link.link[0].link_status : null
}

# EKS Service Discovery Role Output
output "eks_service_discovery_role_arn" {
  description = "ARN of the EKS Service Discovery Role (auto-created or provided)"
  value       = local.eks_service_discovery_role_arn
}

output "eks_service_discovery_role_name" {
  description = "Name of the EKS Service Discovery Role (auto-created or provided)"
  value       = local.eks_service_discovery_role_name
}

# Full Link Object Output
output "link_full_object" {
  description = "Complete link object returned by Cloud Control API"
  value       = var.link.create ? awscc_rtbfabric_link.link[0] : null
}


# Inbound External Link Outputs
output "inbound_external_link_id" {
  description = "Link ID of the created inbound external link"
  value       = var.inbound_external_link.create ? awscc_rtbfabric_inbound_external_link.inbound_external_link[0].link_id : null
}

output "inbound_external_link_arn" {
  description = "ARN of the created inbound external link"
  value       = var.inbound_external_link.create ? awscc_rtbfabric_inbound_external_link.inbound_external_link[0].arn : null
}

output "inbound_external_link_status" {
  description = "Status of the created inbound external link"
  value       = var.inbound_external_link.create ? awscc_rtbfabric_inbound_external_link.inbound_external_link[0].link_status : null
}

output "inbound_external_link_gateway_id" {
  description = "Gateway ID that the inbound external link is attached to"
  value       = var.inbound_external_link.create ? awscc_rtbfabric_inbound_external_link.inbound_external_link[0].gateway_id : null
}

output "inbound_external_link_created_timestamp" {
  description = "Creation timestamp of the inbound external link"
  value       = var.inbound_external_link.create ? awscc_rtbfabric_inbound_external_link.inbound_external_link[0].created_timestamp : null
}

output "inbound_external_link_updated_timestamp" {
  description = "Last update timestamp of the inbound external link"
  value       = var.inbound_external_link.create ? awscc_rtbfabric_inbound_external_link.inbound_external_link[0].updated_timestamp : null
}
