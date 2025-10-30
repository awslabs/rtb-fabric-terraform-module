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



# Kubernetes provider configuration is provided externally by the user
# This allows the module to work with count, for_each, and depends_on

# Create namespace-scoped Role for specific endpoint access
resource "kubernetes_role" "rtbfabric_endpoint_reader" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_rbac ? 1 : 0

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
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_rbac ? 1 : 0

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