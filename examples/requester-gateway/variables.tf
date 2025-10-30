# Variables for RTB Fabric Requester Gateway Example

variable "cluster_name" {
  description = "Name of the EKS cluster to discover VPC and networking resources from"
  type        = string
  
  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "Cluster name must not be empty."
  }
}