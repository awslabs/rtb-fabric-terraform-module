# Example: RTB Fabric Responder Gateway with EKS Endpoints (Manual Setup)
# This example shows how to use a pre-configured role with manual setup

# Variable for cluster name - customers provide this
variable "cluster_name" {
  description = "Name of the EKS cluster to discover VPC and networking resources from"
  type        = string
  default     = "rtbkit-shapirov-iad"
}

# Use shared EKS cluster discovery logic
module "cluster_discovery" {
  source       = "../common"
  cluster_name = var.cluster_name
}

# Create the EKS Service Discovery Role with all required permissions pre-configured
resource "aws_iam_role" "rtb_fabric_eks_role" {
  name = "MyCompany-RTBFabric-EKS-Discovery-Role"

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

  description = "RTB Fabric EKS Service Discovery Role for manual setup example"

  tags = {
    Name        = "MyCompany-RTBFabric-EKS-Discovery-Role"
    Purpose     = "RTB Fabric EKS Service Discovery"
    Environment = "Production"
    Example     = "Manual Setup"
  }
}

# Pre-attach AmazonEKSViewPolicy (manual setup)
resource "aws_iam_role_policy_attachment" "rtb_fabric_eks_view_policy" {
  role       = aws_iam_role.rtb_fabric_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSViewPolicy"
}

# Pre-create EKS access entry (manual setup)
resource "aws_eks_access_entry" "rtb_fabric_manual" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.rtb_fabric_eks_role.arn
  type          = "STANDARD"
}

# Pre-associate EKS access policy (manual setup)
resource "aws_eks_access_policy_association" "rtb_fabric_manual" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.rtb_fabric_eks_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["default"]
  }

  depends_on = [aws_eks_access_entry.rtb_fabric_manual]
}

module "rtb_fabric" {
  source = "../../"

  # Custom default role name for enterprise naming convention
  rtbfabric_eks_discovery_role_name = "MyCompany-RTBFabric-EKS-Discovery-Role"

  responder_gateway = {
    create = true
    # Replace hyphens with spaces to comply with GA API schema pattern ^[A-Za-z0-9 ]+$
    description        = "terraform responder gateway manual for ${replace(var.cluster_name, "-", " ")}"
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
        eks_service_discovery_role   = aws_iam_role.rtb_fabric_eks_role.name # Use the pre-configured role created above
        auto_create_access           = false                                 # Role already has EKS access configured
        auto_create_rbac             = false                                 # RBAC already configured manually
        auto_create_role             = false
      }
    }

    tags = {
      Environment = "Production"
      Setup       = "Manual"
      EKSCluster  = var.cluster_name
    }
  }

  # The role and all permissions are pre-configured above
  # The module will NOT create any additional resources since auto_create_* = false
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
  description = "ARN of the pre-configured RTB Fabric EKS Service Discovery Role"
  value       = aws_iam_role.rtb_fabric_eks_role.arn
}

output "rtb_fabric_eks_role_name" {
  description = "Name of the pre-configured RTB Fabric EKS Service Discovery Role"
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
