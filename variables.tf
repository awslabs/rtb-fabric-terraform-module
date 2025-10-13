variable "requester_app" {
  description = "Requester RTB app configuration"
  type = object({
    create             = optional(bool, false)
    app_name           = optional(string)
    description        = optional(string)
    vpc_id             = optional(string)
    subnet_ids         = optional(list(string))
    security_group_ids = optional(list(string))
    client_token       = optional(string)
    tags = optional(list(object({
      key   = string
      value = string
    })), [])
  })
  default = {}

  validation {
    condition = var.requester_app.app_name == null || (
      length(var.requester_app.app_name) >= 1 &&
      length(var.requester_app.app_name) <= 255
    )
    error_message = "AppName must be between 1 and 255 characters."
  }

  validation {
    condition     = var.requester_app.description == null || can(regex("^[A-Za-z0-9 ]+$", var.requester_app.description))
    error_message = "Description must contain only alphanumeric characters and spaces."
  }

  validation {
    condition = var.requester_app.vpc_id == null || (
      length(var.requester_app.vpc_id) >= 5 &&
      length(var.requester_app.vpc_id) <= 50
    )
    error_message = "VpcId must be between 5 and 50 characters."
  }

  validation {
    condition     = var.requester_app.tags == null || length(var.requester_app.tags) <= 50
    error_message = "Maximum of 50 tags allowed."
  }
}

variable "responder_app" {
  description = "Responder RTB app configuration"
  type = object({
    create               = optional(bool, false)
    app_name             = optional(string)
    description          = optional(string)
    vpc_id               = optional(string)
    subnet_ids           = optional(list(string))
    security_group_ids   = optional(list(string))
    client_token         = optional(string)
    port                 = optional(number)
    protocol             = optional(string, "HTTPS")
    dns_name             = string
    ca_certificate_chain = optional(string)
    managed_endpoint_configuration = optional(object({
      auto_scaling_groups_configuration = optional(object({
        auto_scaling_group_name_list = list(string)
        role_arn                     = string
      }))
      target_groups_configuration = optional(object({
        target_group_arns = list(string)
      }))
      eks_endpoints_configuration = optional(object({
        endpoints_resource_name                 = string
        endpoints_resource_namespace            = string
        cluster_name                            = string
        role_arn                                = optional(string)
        cluster_api_server_endpoint_uri         = optional(string)
        cluster_api_server_ca_certificate_chain = optional(string)
        auto_create_access                      = optional(bool, true)
        auto_create_rbac                        = optional(bool, true)
        cluster_access_role_arn                 = optional(string)
      }))
    }))
    tags = optional(list(object({
      key   = string
      value = string
    })), [])
  })

  validation {
    condition = var.responder_app.app_name == null || (
      length(var.responder_app.app_name) >= 1 &&
      length(var.responder_app.app_name) <= 255
    )
    error_message = "AppName must be between 1 and 255 characters."
  }

  validation {
    condition     = var.responder_app.description == null || can(regex("^[A-Za-z0-9 ]+$", var.responder_app.description))
    error_message = "Description must contain only alphanumeric characters and spaces."
  }

  validation {
    condition = var.responder_app.vpc_id == null || (
      length(var.responder_app.vpc_id) >= 5 &&
      length(var.responder_app.vpc_id) <= 50
    )
    error_message = "VpcId must be between 5 and 50 characters."
  }

  validation {
    condition = var.responder_app.port == null || (
      var.responder_app.port >= 1 &&
      var.responder_app.port <= 65535
    )
    error_message = "Port must be between 1 and 65535."
  }

  validation {
    condition     = var.responder_app.protocol == null || contains(["HTTP", "HTTPS"], var.responder_app.protocol)
    error_message = "Protocol must be either HTTP or HTTPS."
  }

  validation {
    condition     = var.responder_app.dns_name == null || can(regex("^(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)(?:\\.(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?))+$", var.responder_app.dns_name))
    error_message = "DnsName must be a valid domain name."
  }

  validation {
    condition = var.responder_app.ca_certificate_chain == null || (
      length(var.responder_app.ca_certificate_chain) >= 1 &&
      length(var.responder_app.ca_certificate_chain) <= 2097152
    )
    error_message = "CaCertificateChain must be between 1 and 2097152 characters."
  }

  validation {
    condition     = var.responder_app.tags == null || length(var.responder_app.tags) <= 50
    error_message = "Maximum of 50 tags allowed."
  }

  validation {
    condition = (
      var.responder_app.managed_endpoint_configuration == null ||
      var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration == null ||
      (
        var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_name != null &&
        var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_namespace != null &&
        var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name != null
      )
    )
    error_message = "endpoints_resource_name, endpoints_resource_namespace, and cluster_name are required when using EKS endpoints configuration."
  }
}

variable "link" {
  description = "RTB fabric link configuration"
  type = object({
    create                 = optional(bool, false)
    rtb_app_id             = optional(string)
    peer_rtb_app_id        = optional(string)
    http_responder_allowed = optional(bool)
    link_attributes = optional(object({
      responder_error_masking = optional(list(object({
        http_code                   = string
        action                      = string
        logging_types               = list(string)
        response_logging_percentage = optional(number)
      })))
      customer_provided_id = optional(string)
    }))
    link_log_settings = optional(object({
      service_logs = optional(object({
        link_service_log_sampling = object({
          error_log  = optional(number)
          filter_log = optional(number)
        })
      }))
      analytics_logs = optional(object({
        link_analytics_log_sampling = object({
          bid_log = optional(number)
        })
      }))
    }))
    tags = optional(list(object({
      key   = string
      value = string
    })), [])
  })
  default = {}

  validation {
    condition     = var.link.rtb_app_id == null || can(regex("^rtbapp-[a-z0-9-]{1,25}$", var.link.rtb_app_id))
    error_message = "RtbAppId must match pattern ^rtbapp-[a-z0-9-]{1,25}$."
  }

  validation {
    condition     = var.link.peer_rtb_app_id == null || can(regex("^rtbapp-[a-z0-9-]{1,25}$", var.link.peer_rtb_app_id))
    error_message = "PeerRtbAppId must match pattern ^rtbapp-[a-z0-9-]{1,25}$."
  }

  validation {
    condition     = var.link.tags == null || length(var.link.tags) <= 50
    error_message = "Maximum of 50 tags allowed."
  }
}