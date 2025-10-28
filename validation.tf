# Validation checks for EKS Service Discovery Role configuration

# Validate service discovery role trust policy in manual mode
resource "null_resource" "validate_service_discovery_role_trust_policy" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role != null && !var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_access ? 1 : 0

  triggers = {
    service_discovery_role_arn = local.eks_service_discovery_role_arn
    has_trust                  = local.service_discovery_role_has_rtbfabric_trust
  }

  provisioner "local-exec" {
    command = local.service_discovery_role_has_rtbfabric_trust ? "echo 'Trust policy validation passed'" : "echo 'ERROR: EKS Service Discovery Role trust policy validation failed. The role ${local.eks_service_discovery_role_arn} does not include required RTB Fabric service principals: rtbfabric.amazonaws.com, rtbfabric-endpoints.amazonaws.com. Please update the role trust policy or set auto_create_access = true.' && exit 1"
  }
}

# Note: EKS policy validation is skipped to avoid unsupported data source issues
# Users should ensure AmazonEKSViewPolicy is attached when auto_create_access = false

# Check for EKS cluster access in manual mode
data "aws_eks_access_entry" "service_discovery_role_access" {
  count         = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role != null && !var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_access ? 1 : 0
  cluster_name  = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name
  principal_arn = local.eks_service_discovery_role_arn
}

resource "null_resource" "validate_service_discovery_role_eks_access" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role != null && !var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_access ? 1 : 0

  triggers = {
    service_discovery_role_arn = local.eks_service_discovery_role_arn
    cluster_name               = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name
    has_access                 = length(data.aws_eks_access_entry.service_discovery_role_access) > 0
  }

  provisioner "local-exec" {
    command = length(data.aws_eks_access_entry.service_discovery_role_access) > 0 ? "echo 'EKS access validation passed'" : "echo 'ERROR: EKS cluster access not configured. The role ${local.eks_service_discovery_role_arn} does not have access to cluster ${var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name}. Please create an EKS access entry or set auto_create_access = true.' && exit 1"
  }
}

# Note: RBAC validation is skipped in this version to avoid complex kubectl dependencies
# Users should ensure RBAC is properly configured when auto_create_rbac = false
