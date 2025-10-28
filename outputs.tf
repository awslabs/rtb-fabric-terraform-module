# Requester Gateway Outputs
output "requester_gateway_id" {
  description = "ID of the created requester RTB gateway"
  value       = var.requester_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.requester_gateway[0].properties).GatewayId : null
}

output "requester_gateway_arn" {
  description = "ARN of the created requester RTB gateway"
  value       = var.requester_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.requester_gateway[0].properties).Arn : null
}

output "requester_gateway_domain_name" {
  description = "Domain name of the created requester RTB gateway"
  value       = var.requester_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.requester_gateway[0].properties).DomainName : null
}

output "requester_gateway_status" {
  description = "Status of the created requester RTB gateway"
  value       = var.requester_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.requester_gateway[0].properties).RequesterGatewayStatus : null
}

output "requester_active_links_count" {
  description = "Number of active links for the requester gateway"
  value       = var.requester_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.requester_gateway[0].properties).ActiveLinksCount : null
}

output "requester_total_links_count" {
  description = "Total number of links for the requester gateway"
  value       = var.requester_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.requester_gateway[0].properties).TotalLinksCount : null
}

output "requester_gateway_created_timestamp" {
  description = "Creation timestamp of the requester gateway"
  value       = var.requester_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.requester_gateway[0].properties).CreatedTimestamp : null
}

output "requester_gateway_updated_timestamp" {
  description = "Last update timestamp of the requester gateway"
  value       = var.requester_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.requester_gateway[0].properties).UpdatedTimestamp : null
}

# Responder Gateway Outputs
output "responder_gateway_id" {
  description = "ID of the created responder RTB gateway"
  value       = var.responder_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.responder_gateway[0].properties).GatewayId : null
}

output "responder_gateway_arn" {
  description = "ARN of the created responder RTB gateway"
  value       = var.responder_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.responder_gateway[0].properties).Arn : null
}

output "responder_gateway_domain_name" {
  description = "Domain name of the created responder RTB gateway (read-only)"
  value       = var.responder_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.responder_gateway[0].properties).DomainName : null
}

output "responder_gateway_status" {
  description = "Status of the created responder RTB gateway"
  value       = var.responder_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.responder_gateway[0].properties).ResponderGatewayStatus : null
}

output "responder_gateway_created_timestamp" {
  description = "Creation timestamp of the responder gateway"
  value       = var.responder_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.responder_gateway[0].properties).CreatedTimestamp : null
}

output "responder_gateway_updated_timestamp" {
  description = "Last update timestamp of the responder gateway"
  value       = var.responder_gateway.create ? jsondecode(aws_cloudcontrolapi_resource.responder_gateway[0].properties).UpdatedTimestamp : null
}

# Link Outputs
output "link_id" {
  description = "ID of the created RTB fabric link"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).LinkId : null
}

output "link_arn" {
  description = "ARN of the created RTB fabric link"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).Arn : null
}

output "link_status" {
  description = "Status of the created RTB fabric link"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).LinkStatus : null
}

output "link_direction" {
  description = "Direction of the created RTB fabric link"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).LinkDirection : null
}

output "link_created_timestamp" {
  description = "Created timestamp of the RTB fabric link"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).CreatedTimestamp : null
}

output "link_updated_timestamp" {
  description = "Updated timestamp of the RTB fabric link"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).UpdatedTimestamp : null
}

# Legacy output names for backward compatibility
output "link_state" {
  description = "State of the created RTB fabric link (legacy name)"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).LinkStatus : null
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
