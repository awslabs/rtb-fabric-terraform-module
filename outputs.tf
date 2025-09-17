output "app_id" {
  description = "ID of the created RTB application"
  value       = awscc_rtb_fabric_requester_rtb_app.this.id
}

output "app_arn" {
  description = "ARN of the created RTB application"
  value       = awscc_rtb_fabric_requester_rtb_app.this.arn
}
