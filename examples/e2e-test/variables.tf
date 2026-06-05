# Variables for RTB Fabric E2E Test Example

variable "requester_cluster_name" {
  description = "Name of the EKS cluster for the requester gateway"
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Za-z][A-Za-z0-9_-]{0,99}$", var.requester_cluster_name))
    error_message = "requester_cluster_name must be 1-100 characters, start with a letter or digit, and contain only letters, digits, hyphens, and underscores (per EKS cluster naming rules)."
  }
}

variable "responder_cluster_name" {
  description = "Name of the EKS cluster for the responder gateway"
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Za-z][A-Za-z0-9_-]{0,99}$", var.responder_cluster_name))
    error_message = "responder_cluster_name must be 1-100 characters, start with a letter or digit, and contain only letters, digits, hyphens, and underscores (per EKS cluster naming rules)."
  }
}

variable "kubernetes_auth_role_name" {
  description = "IAM role name for Kubernetes provider authentication. If null, uses current AWS credentials."
  type        = string
  default     = null

  validation {
    condition     = var.kubernetes_auth_role_name == null || can(regex("^[a-zA-Z][a-zA-Z0-9_+=,.@-]{0,63}$", var.kubernetes_auth_role_name))
    error_message = "kubernetes_auth_role_name must be a valid IAM role name (1-64 characters, start with letter, alphanumeric and _+=,.@- allowed)."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}
