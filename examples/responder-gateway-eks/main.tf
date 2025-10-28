# Variable for cluster name - customers provide this
variable "cluster_name" {
  description = "Name of the EKS cluster to discover VPC and networking resources from"
  type        = string
  default     = "rtbkit-shapirov-iad"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Use shared EKS cluster discovery logic
module "cluster_discovery" {
  source       = "../common"
  cluster_name = var.cluster_name
}

module "rtb_fabric" {
  source = "../../"

  # Optional: Customize the EKS Discovery Role name for enterprise naming conventions
  # rtbfabric_eks_discovery_role_name = "MyCompany-RTBFabric-EKS-Discovery-Role"

  responder_gateway = {
    create = true
    # Replace hyphens with spaces to comply with GA API schema pattern ^[A-Za-z0-9 ]+$
    description        = "terraform responder gateway for ${replace(var.cluster_name, "-", " ")}"
    vpc_id             = module.cluster_discovery.discovered_vpc_id
    subnet_ids         = module.cluster_discovery.discovered_private_subnet_ids
    security_group_ids = [module.cluster_discovery.discovered_security_group_id]
    port               = 8090
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder-internal"
        endpoints_resource_namespace = "default"
        cluster_name                 = var.cluster_name
        # eks_service_discovery_role not specified - will create default role automatically
        # cluster_access_role_arn if not specified - will use current Terraform credentials
        cluster_access_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/rtbkit-shapirov-iad-EksAccessRole-CA7FhiO8nskv"
        auto_create_access      = true
        auto_create_rbac        = true

        # cluster_api_server_endpoint_uri automatically retrieved
        # cluster_api_server_ca_certificate_chain automatically retrieved
      }
    }

    tags = [
      {
        key   = "Environment"
        value = "Test"
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
  description = "The ID of the responder gateway"
  value       = module.rtb_fabric.responder_gateway_id
}

output "gateway_arn" {
  description = "The ARN of the responder gateway"
  value       = module.rtb_fabric.responder_gateway_arn
}

output "gateway_status" {
  description = "The status of the responder gateway"
  value       = module.rtb_fabric.responder_gateway_status
}

output "gateway_domain_name" {
  description = "The domain name of the responder gateway"
  value       = module.rtb_fabric.responder_gateway_domain_name
}

# Discovery outputs for reference
output "discovered_vpc_id" {
  description = "VPC ID discovered from cluster tags"
  value       = module.cluster_discovery.discovered_vpc_id
}

output "discovered_private_subnet_ids" {
  description = "Private subnet IDs discovered from cluster tags"
  value       = module.cluster_discovery.discovered_private_subnet_ids
}

output "discovered_security_group_id" {
  description = "Security group ID from EKS cluster"
  value       = module.cluster_discovery.discovered_security_group_id
}
