# Variables for RTB Fabric Responder Gateway EKS Hybrid Example

variable "cluster_name" {
  description = "Name of the EKS cluster to discover VPC and networking resources from"
  type        = string
  
  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "Cluster name must not be empty."
  }
}

variable "kubernetes_auth_role_name" {
  description = "IAM role name for Kubernetes provider authentication. If null, uses current AWS credentials."
  type        = string
  default     = null
  
  validation {
    condition = var.kubernetes_auth_role_name == null || can(regex("^[a-zA-Z][a-zA-Z0-9_+=,.@-]{0,63}$", var.kubernetes_auth_role_name))
    error_message = "kubernetes_auth_role_name must be a valid IAM role name (1-64 characters, start with letter, alphanumeric and _+=,.@- allowed)."
  }
}