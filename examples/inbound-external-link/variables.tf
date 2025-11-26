variable "gateway_id" {
  description = "The responder gateway ID to attach the inbound external link to"
  type        = string

  validation {
    condition     = can(regex("^rtb-gw-[a-z0-9-]{1,25}$", var.gateway_id))
    error_message = "Gateway ID must match pattern ^rtb-gw-[a-z0-9-]{1,25}$."
  }
}

variable "customer_provided_id" {
  description = "Optional customer-provided identifier for the link"
  type        = string
  default     = null
}
