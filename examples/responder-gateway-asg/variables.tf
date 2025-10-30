# Variables for RTB Fabric Responder Gateway ASG Example

variable "vpc_id" {
  description = "VPC ID where the responder gateway will be deployed"
  type        = string
  
  validation {
    condition     = can(regex("^vpc-[0-9a-f]{8,17}$", var.vpc_id))
    error_message = "VPC ID must be a valid AWS VPC identifier (vpc-xxxxxxxx)."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs where the responder gateway will be deployed"
  type        = list(string)
  
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
  
  validation {
    condition = alltrue([
      for subnet_id in var.subnet_ids : can(regex("^subnet-[0-9a-f]{8,17}$", subnet_id))
    ])
    error_message = "All subnet IDs must be valid AWS subnet identifiers (subnet-xxxxxxxx)."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs for the responder gateway"
  type        = list(string)
  
  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security group ID must be provided."
  }
  
  validation {
    condition = alltrue([
      for sg_id in var.security_group_ids : can(regex("^sg-[0-9a-f]{8,17}$", sg_id))
    ])
    error_message = "All security group IDs must be valid AWS security group identifiers (sg-xxxxxxxx)."
  }
}

variable "auto_scaling_group_names" {
  description = "List of Auto Scaling Group names for managed endpoint discovery"
  type        = list(string)
  
  validation {
    condition     = length(var.auto_scaling_group_names) > 0
    error_message = "At least one Auto Scaling Group name must be provided."
  }
}