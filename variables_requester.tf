# Requester RTB App Variables
variable "create_requester_app" {
  description = "Whether to create a requester RTB app"
  type        = bool
  default     = false
}

variable "requester_app_name" {
  description = "Name of the requester RTB application"
  type        = string
  default     = null
}

variable "requester_description" {
  description = "Description of the requester RTB application"
  type        = string
  default     = null
}

variable "requester_vpc_id" {
  description = "VPC ID where the requester RTB application will be deployed"
  type        = string
  default     = null
}

variable "requester_subnet_ids" {
  description = "List of subnet IDs for the requester RTB application"
  type        = list(string)
  default     = null
}

variable "requester_security_group_ids" {
  description = "List of security group IDs for the requester RTB application"
  type        = list(string)
  default     = null
}

variable "requester_client_token" {
  description = "Client token for the requester RTB application"
  type        = string
  default     = null
}

variable "requester_tags" {
  description = "Tags to apply to the requester RTB application"
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}