# Local values for computed configurations
locals {
  # EKS Service Discovery Role name - use provided role name or default
  eks_service_discovery_role_name = var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null ? (
    var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role != null ?
    var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role :
    var.rtbfabric_eks_discovery_role_name
  ) : null

  # EKS Service Discovery Role ARN - computed from role name
  eks_service_discovery_role_arn = local.eks_service_discovery_role_name != null ? (
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.eks_service_discovery_role_name}"
  ) : null
}