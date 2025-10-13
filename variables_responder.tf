# Responder RTB App Variables
variable "create_responder_app" {
  description = "Whether to create a responder RTB app"
  type        = bool
  default     = false
}

variable "responder_app_name" {
  description = "Name of the responder RTB application"
  type        = string
  default     = null
}

variable "responder_description" {
  description = "Description of the responder RTB application"
  type        = string
  default     = null
}

variable "responder_vpc_id" {
  description = "VPC ID where the responder RTB application will be deployed"
  type        = string
  default     = null
}

variable "responder_subnet_ids" {
  description = "List of subnet IDs for the responder RTB application"
  type        = list(string)
  default     = null
}

variable "responder_security_group_ids" {
  description = "List of security group IDs for the responder RTB application"
  type        = list(string)
  default     = null
}

variable "responder_port" {
  description = "Port for the responder RTB application"
  type        = number
  default     = null
}

variable "responder_protocol" {
  description = "Protocol for the responder RTB application (HTTP or HTTPS)"
  type        = string
  default     = "HTTPS"
  validation {
    condition     = var.responder_protocol == null || contains(["HTTP", "HTTPS"], var.responder_protocol)
    error_message = "Protocol must be either HTTP or HTTPS."
  }
}

variable "responder_dns_name" {
  description = "DNS name for the responder RTB application"
  type        = string
  default     = null
}

variable "responder_ca_certificate_chain" {
  description = "CA certificate chain for the responder RTB application"
  type        = string
  default     = null
}

variable "responder_managed_endpoint_configuration" {
  description = "Managed endpoint configuration for EKS responder app"
  type = object({
    eks_endpoints_configuration = object({
      endpoints_resource_name                 = string
      endpoints_resource_namespace            = string
      cluster_api_server_endpoint_uri         = string
      cluster_api_server_ca_certificate_chain = string
      cluster_name                            = string
      role_arn                                = string
    })
  })
  default = null
}

variable "responder_tags" {
  description = "Tags to apply to the responder RTB application"
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}