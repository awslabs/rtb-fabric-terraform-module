# Requester App Outputs
output "requester_app_id" {
  description = "ID of the created requester RTB application"
  value       = var.requester_app.create ? jsondecode(aws_cloudcontrolapi_resource.requester_app[0].properties).RtbAppId : null
}

output "requester_app_arn" {
  description = "ARN of the created requester RTB application"
  value       = var.requester_app.create ? jsondecode(aws_cloudcontrolapi_resource.requester_app[0].properties).Arn : null
}

output "requester_app_endpoint" {
  description = "Endpoint of the created requester RTB application"
  value       = var.requester_app.create ? jsondecode(aws_cloudcontrolapi_resource.requester_app[0].properties).RtbAppEndpoint : null
}

output "requester_app_status" {
  description = "Status of the created requester RTB application"
  value       = var.requester_app.create ? jsondecode(aws_cloudcontrolapi_resource.requester_app[0].properties).Status : null
}

# Responder App Outputs
output "responder_app_id" {
  description = "ID of the created responder RTB application"
  value       = var.responder_app.create ? jsondecode(aws_cloudcontrolapi_resource.responder_app[0].properties).RtbAppId : null
}

output "responder_app_arn" {
  description = "ARN of the created responder RTB application"
  value       = var.responder_app.create ? jsondecode(aws_cloudcontrolapi_resource.responder_app[0].properties).Arn : null
}

output "responder_app_status" {
  description = "Status of the created responder RTB application"
  value       = var.responder_app.create ? jsondecode(aws_cloudcontrolapi_resource.responder_app[0].properties).Status : null
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

output "link_state" {
  description = "State of the created RTB fabric link"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).LinkState : null
}

output "link_direction" {
  description = "Direction of the created RTB fabric link"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).LinkDirection : null
}

output "link_public_endpoint" {
  description = "Public endpoint of the created RTB fabric link"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).PublicEndpoint : null
}

output "link_created_timestamp" {
  description = "Created timestamp of the RTB fabric link"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).CreatedTimestamp : null
}

output "link_updated_timestamp" {
  description = "Updated timestamp of the RTB fabric link"
  value       = var.link.create ? jsondecode(aws_cloudcontrolapi_resource.link[0].properties).UpdatedTimestamp : null
}
