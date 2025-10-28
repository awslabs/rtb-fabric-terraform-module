# Outputs for use by examples
output "discovered_vpc_id" {
  description = "VPC ID discovered from cluster tags"
  value       = local.cluster_vpc_id
}

output "discovered_private_subnet_ids" {
  description = "Subnet IDs discovered from cluster tags"
  value       = data.aws_subnets.cluster_subnets.ids
}

output "discovered_security_group_id" {
  description = "Security group ID from EKS cluster"
  value       = local.cluster_security_group_id
}

output "cluster_name_used" {
  description = "Cluster name used for resource discovery"
  value       = var.cluster_name
}