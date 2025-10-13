# Local values for computed configurations
locals {
  # Default HeimdallAssumeRole ARN for current account
  default_heimdall_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/HeimdallAssumeRole"

  # Computed role ARN for EKS configuration
  eks_role_arn = var.responder_app.managed_endpoint_configuration != null && var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration != null ? (
    var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.role_arn != null ?
    var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.role_arn :
    local.default_heimdall_role_arn
  ) : null
}