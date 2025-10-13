# RTB Fabric Link Variables
variable "create_link" {
  description = "Whether to create an RTB fabric link"
  type        = bool
  default     = false
}

variable "link_name" {
  description = "Name of the RTB fabric link"
  type        = string
  default     = null
}

variable "link_description" {
  description = "Description of the RTB fabric link"
  type        = string
  default     = null
}

variable "link_requester_rtb_app_arn" {
  description = "ARN of the requester RTB app to link"
  type        = string
  default     = null
}

variable "link_responder_rtb_app_arn" {
  description = "ARN of the responder RTB app to link"
  type        = string
  default     = null
}

variable "link_configuration" {
  description = "Configuration for the RTB fabric link"
  type        = any
  default     = null
}

variable "link_tags" {
  description = "Tags to apply to the RTB fabric link"
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}