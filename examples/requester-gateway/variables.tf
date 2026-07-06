# Variables for RTB Fabric Requester Gateway Example

variable "cluster_name" {
  description = "Name of the EKS cluster to discover VPC and networking resources from"
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Za-z][A-Za-z0-9_-]{0,99}$", var.cluster_name))
    error_message = "cluster_name must be 1-100 characters, start with a letter or digit, and contain only letters, digits, hyphens, and underscores (per EKS cluster naming rules)."
  }
}