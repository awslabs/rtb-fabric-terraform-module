# Variable for cluster name - customers provide this
variable "cluster_name" {
  description = "Name of the EKS cluster to discover VPC and networking resources from"
  type        = string
  default     = "rtbkit-shapirov-iad"
}

# Use shared EKS cluster discovery logic
module "cluster_discovery" {
  source = "../common"
  cluster_name = var.cluster_name
}

module "rtb_fabric" {
  source = "../../"

  requester_gateway = {
    create             = true
    # Replace hyphens with spaces to comply with GA API schema pattern ^[A-Za-z0-9 ]+$
    description        = "terraform requester gateway for ${replace(var.cluster_name, "-", " ")}"
    vpc_id             = module.cluster_discovery.discovered_vpc_id
    subnet_ids         = module.cluster_discovery.discovered_private_subnet_ids
    security_group_ids = [module.cluster_discovery.discovered_security_group_id]
    tags = [
      {
        key   = "Environment"
        value = "Prod"
      },
      {
        key   = "EKSCluster"
        value = var.cluster_name
      }
    ]
  }
}

# Main gateway outputs
output "gateway_id" {
  description = "The ID of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_id
}

output "gateway_arn" {
  description = "The ARN of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_arn
}

output "gateway_status" {
  description = "The status of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_status
}

output "gateway_domain_name" {
  description = "The domain name of the requester gateway"
  value       = module.rtb_fabric.requester_gateway_domain_name
}

# Discovery outputs for reference
output "discovered_vpc_id" {
  description = "VPC ID discovered from cluster tags"
  value       = module.cluster_discovery.discovered_vpc_id
}

output "discovered_private_subnet_ids" {
  description = "Subnet IDs discovered from cluster tags"
  value       = module.cluster_discovery.discovered_private_subnet_ids
}

output "discovered_security_group_id" {
  description = "Security group ID from EKS cluster"
  value       = module.cluster_discovery.discovered_security_group_id
}