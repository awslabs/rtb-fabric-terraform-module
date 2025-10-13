output "requester_app_id" {
  description = "ID of the requester RTB application"
  value       = module.rtb_fabric.requester_app_id
}

output "requester_app_endpoint" {
  description = "Endpoint of the requester RTB application"
  value       = module.rtb_fabric.requester_app_endpoint
}

output "eks_responder_app_id" {
  description = "ID of the EKS responder RTB application"
  value       = module.rtb_fabric.responder_app_id
}

output "asg_responder_app_id" {
  description = "ID of the ASG responder RTB application"
  value       = module.rtb_fabric_asg.responder_app_id
}

output "eks_link_id" {
  description = "ID of the link to EKS responder"
  value       = module.rtb_fabric_links.link_id
}

output "asg_link_id" {
  description = "ID of the link to ASG responder"
  value       = module.rtb_fabric_links_asg.link_id
}