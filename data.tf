# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Note: Policy attachment validation is skipped to avoid unsupported data source issues
# Users should ensure proper policies are attached when auto_create_access = false