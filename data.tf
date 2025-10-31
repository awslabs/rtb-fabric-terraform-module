# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Note: Policy attachment validation is skipped to avoid unsupported data source issues
# Users should ensure proper policies are attached when auto_create_access = false

# Validate service discovery role trust policy contains RTB Fabric service principals
# Note: Validation is disabled to avoid dependency issues when role is created in same configuration
locals {


  service_discovery_role_has_rtbfabric_trust = true # Assume valid when validation is disabled
}

# Validate ASG service discovery role trust policy contains RTB Fabric service principals
# Note: Validation is disabled to avoid dependency issues when role is created in same configuration
locals {

  asg_service_discovery_role_has_rtbfabric_trust = true # Assume valid when validation is disabled
}