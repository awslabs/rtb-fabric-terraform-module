output "responder_app_id" {
  description = "ID of the created basic responder RTB application"
  value       = module.rtb_fabric.responder_app_id
}

output "responder_app_arn" {
  description = "ARN of the created basic responder RTB application"
  value       = module.rtb_fabric.responder_app_arn
}

output "responder_app_status" {
  description = "Status of the created basic responder RTB application"
  value       = module.rtb_fabric.responder_app_status
}