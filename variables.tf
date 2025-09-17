variable "app_name" {
  description = "Name of the RTB application"
  type        = string
}

variable "description" {
  description = "Description of the RTB application"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the RTB application will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RTB application"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the RTB application"
  type        = list(string)
}

variable "client_token" {
  description = "Client token for the RTB application"
  type        = string
}
