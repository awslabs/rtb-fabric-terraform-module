# Kubernetes Provider Configuration for EKS
# Authentication is configured via kubernetes_auth_role_name variable

# Construct role ARN dynamically if role name is provided
locals {
  auth_role_arn = var.kubernetes_auth_role_name != null ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.kubernetes_auth_role_name}" : null
}

provider "kubernetes" {
  host                   = module.cluster_discovery.discovered_cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster_discovery.discovered_cluster_ca_certificate)
  alias                  = "responder"
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = local.auth_role_arn != null ? [
      "eks", "get-token", "--cluster-name", var.cluster_name,
      "--role-arn", local.auth_role_arn
      ] : [
      "eks", "get-token", "--cluster-name", var.cluster_name
    ]
  }
}