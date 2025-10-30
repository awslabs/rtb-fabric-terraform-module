# Kubernetes Provider Configuration for EKS
# Customize the auth_role_arn below for your authentication needs

locals {
  # Configuration parameters - modify these as needed
  cluster_name  = var.cluster_name
  auth_role_arn = null # Set to your role ARN if needed: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/MyRole"
}

provider "kubernetes" {
  host                   = module.cluster_discovery.discovered_cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster_discovery.discovered_cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = local.auth_role_arn != null ? [
      "eks", "get-token", "--cluster-name", local.cluster_name,
      "--role-arn", local.auth_role_arn
      ] : [
      "eks", "get-token", "--cluster-name", local.cluster_name
    ]
  }
}
