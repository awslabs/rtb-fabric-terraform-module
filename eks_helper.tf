# EKS Cluster Data Source
data "aws_eks_cluster" "cluster" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null ? 1 : 0
  name  = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name
}

# Create EKS Access Entry for Service Discovery Role
resource "aws_eks_access_entry" "rtbfabric" {
  count         = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_access ? 1 : 0
  cluster_name  = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name
  principal_arn = local.eks_service_discovery_role_arn
  type          = "STANDARD"
  user_name     = local.eks_service_discovery_role_arn
}

# Associate EKS Access Policy with Access Entry for the specified namespace
resource "aws_eks_access_policy_association" "rtbfabric" {
  count         = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_access ? 1 : 0
  cluster_name  = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name
  principal_arn = local.eks_service_discovery_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type       = "namespace"
    namespaces = [var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_namespace]
  }

  depends_on = [aws_eks_access_entry.rtbfabric]
}



# Kubernetes Provider for RBAC - uses cluster_access_role_arn if provided, otherwise current credentials
provider "kubernetes" {
  alias = "eks"

  host                   = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null ? data.aws_eks_cluster.cluster[0].endpoint : null
  cluster_ca_certificate = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null ? base64decode(data.aws_eks_cluster.cluster[0].certificate_authority[0].data) : null

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null ? (
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_access_role_arn != null ?
      ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster[0].name, "--role-arn", var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_access_role_arn] :
      ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster[0].name]
    ) : []
  }
}

# Create namespace-scoped Role for specific endpoint access
resource "kubernetes_role" "rtbfabric_endpoint_reader" {
  count    = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_rbac ? 1 : 0
  provider = kubernetes.eks

  metadata {
    namespace = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_namespace
    name      = "rtbfabric-endpoint-reader"
  }

  rule {
    api_groups     = [""]
    resources      = ["endpoints"]
    resource_names = [var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_name]
    verbs          = ["get"]
  }
}

# Create namespace-scoped RoleBinding
resource "kubernetes_role_binding" "rtbfabric_endpoint_reader" {
  count    = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_rbac ? 1 : 0
  provider = kubernetes.eks

  metadata {
    namespace = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_namespace
    name      = "rtbfabric-endpoint-reader"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.rtbfabric_endpoint_reader[0].metadata[0].name
  }

  subject {
    kind      = "User"
    name      = local.eks_service_discovery_role_arn
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [aws_eks_access_entry.rtbfabric]
}