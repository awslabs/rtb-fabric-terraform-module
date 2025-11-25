# RTB Fabric Responder Gateway using awscc provider
resource "awscc_rtbfabric_responder_gateway" "responder_gateway" {
  count = var.responder_gateway.create ? 1 : 0

  # Required attributes
  vpc_id             = var.responder_gateway.vpc_id
  subnet_ids         = var.responder_gateway.subnet_ids
  security_group_ids = var.responder_gateway.security_group_ids
  port               = var.responder_gateway.port
  protocol           = var.responder_gateway.protocol

  # Optional attributes - pass through directly
  description = var.responder_gateway.description
  domain_name = var.responder_gateway.domain_name
  tags        = var.responder_gateway.tags

  # Trust store configuration
  trust_store_configuration = var.responder_gateway.trust_store_configuration != null ? {
    certificate_authority_certificates = var.responder_gateway.trust_store_configuration.certificate_authority_certificates
  } : null

  # Managed endpoint configuration - supports both EKS and ASG
  managed_endpoint_configuration = var.responder_gateway.managed_endpoint_configuration != null ? {
    # EKS endpoints configuration
    eks_endpoints_configuration = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null ? {
      endpoints_resource_name                 = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_name
      endpoints_resource_namespace            = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_namespace
      cluster_name                            = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name
      role_arn                                = local.eks_service_discovery_role_arn
      cluster_api_server_endpoint_uri         = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_endpoint_uri != null ? var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_endpoint_uri : local.eks_cluster_endpoint
      cluster_api_server_ca_certificate_chain = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_ca_certificate_chain != null ? var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_ca_certificate_chain : local.eks_cluster_ca_data
    } : null

    # ASG configuration
    auto_scaling_groups_configuration = var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration != null ? {
      auto_scaling_group_name_list = var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_scaling_group_name_list
      role_arn                     = local.asg_discovery_role_arn
    } : null
  } : null

  # Ensure required resources are created before the gateway
  # All potential dependencies are listed - Terraform automatically handles conditional resources
  depends_on = [
    aws_iam_role.eks_service_discovery_role,
    aws_iam_role_policy.eks_service_discovery_role_policy,
    aws_iam_role.asg_service_discovery_role,
    aws_iam_role_policy.asg_service_discovery_role_policy,
    aws_eks_access_entry.rtbfabric,
    kubernetes_role.rtbfabric_endpoint_reader,
    kubernetes_role_binding.rtbfabric_endpoint_reader
  ]
}


