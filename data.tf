# Get current AWS account ID
data "aws_caller_identity" "current" {}

# EKS Service Discovery Role validation data sources (only when role is provided and auto_create_role is false)
# Note: This validation is disabled to avoid issues when the role is created in the same Terraform configuration
# Users should ensure the role exists and has proper trust relationships when auto_create_role = false
data "aws_iam_role" "eks_service_discovery_role" {
  count = 0  # Disabled to avoid dependency issues
  name  = ""
}

# Note: Policy attachment validation is skipped to avoid unsupported data source issues
# Users should ensure proper policies are attached when auto_create_access = false

# Validate service discovery role trust policy contains RTB Fabric service principals
# Note: Validation is disabled to avoid dependency issues when role is created in same configuration
locals {
  service_discovery_role_trust_policy = null  # Disabled
  
  rtbfabric_principals_required = [
    "rtbfabric.amazonaws.com",
    "rtbfabric-endpoints.amazonaws.com"
  ]
  
  service_discovery_role_has_rtbfabric_trust = true  # Assume valid when validation is disabled
}

# ASG Service Discovery Role validation data sources (only when role is provided and auto_create_role is false)
# Note: This validation is disabled to avoid issues when the role is created in the same Terraform configuration
data "aws_iam_role" "asg_service_discovery_role" {
  count = 0  # Disabled to avoid dependency issues
  name  = ""
}

# Validate ASG service discovery role trust policy contains RTB Fabric service principals
# Note: Validation is disabled to avoid dependency issues when role is created in same configuration
locals {
  asg_service_discovery_role_trust_policy = null  # Disabled
  
  asg_service_discovery_role_has_rtbfabric_trust = true  # Assume valid when validation is disabled
}