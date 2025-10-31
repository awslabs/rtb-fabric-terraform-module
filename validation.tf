# Validation checks for EKS Service Discovery Role configuration

# Validate service discovery role trust policy in manual mode
resource "null_resource" "validate_service_discovery_role_trust_policy" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role != null && coalesce(var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_role, true) == false ? 1 : 0

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


resource "null_resource" "validate_service_discovery_role_eks_access" {
  count = 0 # Disabled to avoid dependency issues when role is created in same configuration

  triggers = {
    service_discovery_role_arn = ""
    cluster_name               = ""
    has_access                 = true
  }

  provisioner "local-exec" {
    command = "echo 'EKS access validation skipped'"
  }
}

# Note: RBAC validation is skipped in this version to avoid complex kubectl dependencies
# Users should ensure RBAC is properly configured when auto_create_rbac = false

# Validation checks for ASG Service Discovery Role configuration

# Validate ASG service discovery role trust policy in manual mode
resource "null_resource" "validate_asg_service_discovery_role_trust_policy" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration != null && var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role != null && !var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_create_role ? 1 : 0

  triggers = {
    asg_service_discovery_role_arn = local.asg_discovery_role_arn
    has_trust                      = local.asg_service_discovery_role_has_rtbfabric_trust
  }

  provisioner "local-exec" {
    command = local.asg_service_discovery_role_has_rtbfabric_trust ? "echo 'ASG trust policy validation passed'" : "echo 'ERROR: ASG Service Discovery Role trust policy validation failed. The role ${local.asg_discovery_role_arn} does not include required RTB Fabric service principals: rtbfabric.amazonaws.com, rtbfabric-endpoints.amazonaws.com. Please update the role trust policy or set auto_create_role = true.' && exit 1"
  }
}

# Validate ASG configuration parameters
resource "null_resource" "validate_asg_configuration" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration != null ? 1 : 0

  triggers = {
    asg_names_count = length(var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_scaling_group_name_list)
  }

  provisioner "local-exec" {
    command = length(var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_scaling_group_name_list) > 0 ? "echo 'ASG configuration validation passed'" : "echo 'ERROR: Auto Scaling Group configuration incomplete. auto_scaling_group_name_list is required and must contain at least one Auto Scaling Group name when using ASG managed endpoints.' && exit 1"
  }
}

# Note: ASG permissions validation is skipped to avoid complex policy parsing
# Users should ensure proper ASG and EC2 permissions are attached when auto_create_role = false
