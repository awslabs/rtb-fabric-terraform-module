# Kubernetes Provider Configuration for E2E Test
# This example uses the responder cluster for kubernetes provider since only the responder gateway needs EKS RBAC
# Customize the auth_role_arn below for your authentication needs

locals {
  # Configuration parameters - modify these as needed
  # Note: This uses the responder cluster since that's where EKS managed endpoints are configured
  cluster_name  = var.responder_cluster_name
  auth_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/rtbkit-shapirov-iad-EksAccessRole-CA7FhiO8nskv"  # Example role ARN
}

provider "kubernetes" {
  host                   = module.responder_cluster_discovery.discovered_cluster_endpoint
  cluster_ca_certificate = base64decode(module.responder_cluster_discovery.discovered_cluster_ca_certificate)
  alias = "responder"
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