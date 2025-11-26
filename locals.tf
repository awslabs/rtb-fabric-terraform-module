# Local values for computed configurations
locals {

  # Convert Terraform map tags to CloudFormation list format for awscc provider
  requester_tags = length(var.requester_gateway.tags) > 0 ? [
    for key, value in var.requester_gateway.tags : {
      key   = key
      value = value
    }
  ] : []

  responder_tags = length(var.responder_gateway.tags) > 0 ? [
    for key, value in var.responder_gateway.tags : {
      key   = key
      value = value
    }
  ] : []

  link_tags = length(var.link.tags) > 0 ? [
    for key, value in var.link.tags : {
      key   = key
      value = value
    }
  ] : []

  inbound_external_link_tags = length(var.inbound_external_link.tags) > 0 ? [
    for key, value in var.inbound_external_link.tags : {
      key   = key
      value = value
    }
  ] : []

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

  # ASG Discovery Role name - use provided role name or default
  asg_discovery_role_name = var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration != null ? (
    var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role != null ?
    var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role :
    var.rtbfabric_asg_discovery_role_name
  ) : null

  # ASG Discovery Role ARN - computed from role name
  asg_discovery_role_arn = local.asg_discovery_role_name != null ? (
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.asg_discovery_role_name}"
  ) : null

  # EKS Cluster data - safely computed to avoid conditional evaluation issues
  eks_cluster_endpoint = var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && length(data.aws_eks_cluster.cluster) > 0 ? data.aws_eks_cluster.cluster[0].endpoint : ""
  eks_cluster_ca_data  = var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && length(data.aws_eks_cluster.cluster) > 0 ? data.aws_eks_cluster.cluster[0].certificate_authority[0].data : ""

  # Separate configurations for each endpoint type to avoid conditional type issues
  asg_endpoint_config = var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration != null ? {
    AutoScalingGroupsConfiguration = {
      AutoScalingGroupNameList = var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_scaling_group_name_list
      RoleArn                  = local.asg_discovery_role_arn
    }
  } : {}

  eks_endpoint_config = var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null ? {
    EksEndpointsConfiguration = {
      EndpointsResourceName              = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_name
      EndpointsResourceNamespace         = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_namespace
      ClusterApiServerEndpointUri        = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_endpoint_uri != null ? var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_endpoint_uri : local.eks_cluster_endpoint
      ClusterApiServerCaCertificateChain = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_ca_certificate_chain != null ? var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_ca_certificate_chain : local.eks_cluster_ca_data
      ClusterName                        = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name
      RoleArn                            = local.eks_service_discovery_role_arn
    }
  } : {}

  # Merge the configurations - only one will have content
  managed_endpoint_configuration = merge(local.asg_endpoint_config, local.eks_endpoint_config)
}
