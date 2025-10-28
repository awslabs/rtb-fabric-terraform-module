# Get current AWS account ID
data "aws_caller_identity" "current" {}

# EKS Service Discovery Role validation data sources (only when role is provided and manual setup)
data "aws_iam_role" "eks_service_discovery_role" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role != null ? 1 : 0
  name  = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role
}

# Note: Policy attachment validation is skipped to avoid unsupported data source issues
# Users should ensure proper policies are attached when auto_create_access = false

# Validate service discovery role trust policy contains RTB Fabric service principals
locals {
  service_discovery_role_trust_policy = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role != null ? jsondecode(data.aws_iam_role.eks_service_discovery_role[0].assume_role_policy) : null
  
  rtbfabric_principals_required = [
    "rtbfabric.amazonaws.com",
    "rtbfabric-endpoints.amazonaws.com"
  ]
  
  service_discovery_role_has_rtbfabric_trust = local.service_discovery_role_trust_policy != null ? (
    length([
      for stmt in local.service_discovery_role_trust_policy.Statement :
      stmt if contains(keys(stmt), "Principal") && contains(keys(stmt.Principal), "Service") && 
      length(setintersection(
        toset(flatten([stmt.Principal.Service])),
        toset(local.rtbfabric_principals_required)
      )) == length(local.rtbfabric_principals_required)
    ]) > 0
  ) : true
}