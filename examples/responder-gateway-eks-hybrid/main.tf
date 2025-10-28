# Example: RTB Fabric Responder Gateway with EKS Endpoints (Hybrid Setup)
# This example shows how to use an existing role with automatic access/RBAC creation

# Variable for cluster name - customers provide this
variable "cluster_name" {
  description = "Name of the EKS cluster to discover VPC and networking resources from"
  type        = string
  default     = "my-eks-cluster"
}

# Get current AWS account ID for ARN construction
data "aws_caller_identity" "current" {}

# Use shared EKS cluster discovery logic
module "cluster_discovery" {
  source = "../common"
  cluster_name = var.cluster_name
}

# Create the EKS Service Discovery Role that RTB Fabric service will assume
resource "aws_iam_role" "rtb_fabric_eks_role" {
  name = "MyCompany-RTBFabric-EKS-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "rtbfabric.amazonaws.com",
            "rtbfabric-endpoints.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  description = "RTB Fabric EKS Service Discovery Role for hybrid setup example"

  tags = {
    Name        = "MyCompany-RTBFabric-EKS-Role"
    Purpose     = "RTB Fabric EKS Service Discovery"
    Environment = "Staging"
    Example     = "Hybrid Setup"
  }
}

module "rtb_fabric" {
  source = "../../"

  responder_gateway = {
    create             = true
    # Replace hyphens with spaces to comply with GA API schema pattern ^[A-Za-z0-9 ]+$
    description        = "terraform responder gateway hybrid for ${replace(var.cluster_name, "-", " ")}"
    vpc_id             = module.cluster_discovery.discovered_vpc_id
    subnet_ids         = module.cluster_discovery.discovered_private_subnet_ids
    security_group_ids = [module.cluster_discovery.discovered_security_group_id]
    port               = 8080
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder"
        endpoints_resource_namespace = "default"
        cluster_name                 = var.cluster_name
        eks_service_discovery_role   = aws_iam_role.rtb_fabric_eks_role.name # Use the role created above
        # cluster_access_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TerraformEKSAccessRole" # Optional: Custom role for Terraform EKS access
        auto_create_access           = true                                  # But still auto-create EKS access entry
        auto_create_rbac             = true                                  # And auto-create RBAC
      }
    }

    tags = [
      {
        key   = "Environment"
        value = "Staging"
      },
      {
        key   = "Setup"
        value = "Hybrid"
      },
      {
        key   = "EKSCluster"
        value = var.cluster_name
      }
    ]
  }

  # The module will automatically:
  # - Attach AmazonEKSViewPolicy to the role above
  # - Create EKS access entry for the role
  # - Create Kubernetes RBAC for endpoint access
  depends_on = [aws_iam_role.rtb_fabric_eks_role]
}

# Output the created role information
output "rtb_fabric_eks_role_arn" {
  description = "ARN of the created RTB Fabric EKS Service Discovery Role"
  value       = aws_iam_role.rtb_fabric_eks_role.arn
}

output "rtb_fabric_eks_role_name" {
  description = "Name of the created RTB Fabric EKS Service Discovery Role"
  value       = aws_iam_role.rtb_fabric_eks_role.name
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

# Role outputs
output "rtb_fabric_eks_role_arn" {
  description = "ARN of the created RTB Fabric EKS Service Discovery Role"
  value       = aws_iam_role.rtb_fabric_eks_role.arn
}

output "rtb_fabric_eks_role_name" {
  description = "Name of the created RTB Fabric EKS Service Discovery Role"
  value       = aws_iam_role.rtb_fabric_eks_role.name
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