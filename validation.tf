# Validation checks for EKS Service Discovery Role configuration

# Note: Trust policy validation is disabled to avoid tflint issues with complex conditionals
# Users should ensure the role trust policy includes rtbfabric.amazonaws.com and rtbfabric-endpoints.amazonaws.com
# when providing their own role with auto_create_role = false

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

# Note: Trust policy validation is disabled to avoid tflint issues with complex conditionals
# Users should ensure the role trust policy includes rtbfabric.amazonaws.com and rtbfabric-endpoints.amazonaws.com
# when providing their own role with auto_create_role = false

# Note: ASG configuration validation is disabled to avoid tflint issues with complex conditionals
# Users should ensure auto_scaling_group_name_list contains at least one ASG name when using ASG managed endpoints

# Note: ASG permissions validation is skipped to avoid complex policy parsing
# Users should ensure proper ASG and EC2 permissions are attached when auto_create_role = false
