variable "requester_gateway" {
  description = "Requester RTB Fabric gateway configuration for GA schema"
  type = object({
    create             = optional(bool, false)
    description        = optional(string)
    vpc_id             = optional(string)
    subnet_ids         = optional(list(string))
    security_group_ids = optional(list(string))
    tags = optional(list(object({
      key   = string
      value = string
    })), [])
  })
  default = {}

  validation {
    condition = var.requester_gateway.vpc_id == null || (
      length(var.requester_gateway.vpc_id) >= 5 &&
      length(var.requester_gateway.vpc_id) <= 50
    )
    error_message = "VpcId must be between 5 and 50 characters."
  }

  validation {
    condition     = var.requester_gateway.tags == null || length(var.requester_gateway.tags) <= 50
    error_message = "Maximum of 50 tags allowed."
  }

  validation {
    condition = !var.requester_gateway.create || (
      var.requester_gateway.vpc_id != null &&
      var.requester_gateway.subnet_ids != null &&
      var.requester_gateway.security_group_ids != null
    )
    error_message = "When create is true, vpc_id, subnet_ids, and security_group_ids are required."
  }
}

variable "responder_gateway" {
  description = "Responder RTB Fabric gateway configuration with customer-managed role support"
  type = object({
    create             = optional(bool, false)
    description        = optional(string) # GA API field name
    vpc_id             = optional(string)
    subnet_ids         = optional(list(string))
    security_group_ids = optional(list(string))
    port               = optional(number)
    protocol           = optional(string, "HTTPS")
    trust_store_configuration = optional(object({
      certificate_authority_certificates = list(string)
    }))
    managed_endpoint_configuration = optional(object({
      auto_scaling_groups_configuration = optional(object({
        auto_scaling_group_name_list = list(string)
        # New fields replacing role_arn for GA API compatibility
        asg_discovery_role = optional(string) # Role name (not ARN) for RTB Fabric service to assume; creates default if not provided
        auto_create_role   = optional(bool, true)
      }))
      eks_endpoints_configuration = optional(object({
        endpoints_resource_name                 = string
        endpoints_resource_namespace            = string
        cluster_name                            = string
        role_arn                                = optional(string) # GA API field name - will be computed from eks_service_discovery_role
        cluster_api_server_endpoint_uri         = optional(string)
        cluster_api_server_ca_certificate_chain = optional(string)
        # Module-specific fields (not part of GA API)
        eks_service_discovery_role = optional(string) # Role name (not ARN) for RTB Fabric service to assume; creates default if not provided
        cluster_access_role_arn    = optional(string) # Role ARN for Terraform to assume when creating EKS RBAC resources; uses current credentials if not provided
        auto_create_access         = optional(bool, true)
        auto_create_rbac           = optional(bool, true)
      }))
    }))
    tags = optional(list(object({
      key   = string
      value = string
    })), [])
  })
  default = {}

  validation {
    condition = var.responder_gateway.vpc_id == null || (
      length(var.responder_gateway.vpc_id) >= 5 &&
      length(var.responder_gateway.vpc_id) <= 50
    )
    error_message = "VpcId must be between 5 and 50 characters."
  }

  validation {
    condition = var.responder_gateway.port == null || (
      var.responder_gateway.port >= 1 &&
      var.responder_gateway.port <= 65535
    )
    error_message = "Port must be between 1 and 65535."
  }

  validation {
    condition     = var.responder_gateway.protocol == null || contains(["HTTP", "HTTPS"], var.responder_gateway.protocol)
    error_message = "Protocol must be either HTTP or HTTPS."
  }

  validation {
    condition = var.responder_gateway.trust_store_configuration == null || (
      var.responder_gateway.trust_store_configuration.certificate_authority_certificates != null &&
      length(var.responder_gateway.trust_store_configuration.certificate_authority_certificates) > 0
    )
    error_message = "trust_store_configuration.certificate_authority_certificates must contain at least one certificate."
  }

  validation {
    condition     = var.responder_gateway.tags == null || length(var.responder_gateway.tags) <= 50
    error_message = "Maximum of 50 tags allowed."
  }

  validation {
    condition = (
      var.responder_gateway.managed_endpoint_configuration == null ||
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration == null ||
      (
        var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_name != null &&
        var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_namespace != null &&
        var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name != null
      )
    )
    error_message = "endpoints_resource_name, endpoints_resource_namespace, and cluster_name are required when using EKS endpoints configuration."
  }

  validation {
    condition = (
      var.responder_gateway.managed_endpoint_configuration == null ||
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration == null ||
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role == null ||
      can(regex("^[a-zA-Z][a-zA-Z0-9_+=,.@-]{0,63}$", var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role))
    )
    error_message = "eks_service_discovery_role must be a valid IAM role name (1-64 characters, start with letter, alphanumeric and _+=,.@- allowed)"
  }

  validation {
    condition = (
      var.responder_gateway.managed_endpoint_configuration == null ||
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration == null ||
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_access_role_arn == null ||
      can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_access_role_arn))
    )
    error_message = "cluster_access_role_arn must be a valid IAM role ARN (arn:aws:iam::ACCOUNT:role/ROLE_NAME)"
  }



  validation {
    condition = !var.responder_gateway.create || (
      var.responder_gateway.vpc_id != null &&
      var.responder_gateway.subnet_ids != null &&
      var.responder_gateway.security_group_ids != null &&
      var.responder_gateway.port != null &&
      var.responder_gateway.protocol != null
    )
    error_message = "When create is true, vpc_id, subnet_ids, security_group_ids, port, and protocol are required."
  }
}

variable "rtbfabric_eks_discovery_role_name" {
  description = "Name for the RTB Fabric EKS Discovery Role (created when eks_service_discovery_role is not provided). The module will use an existing role with this name if found, otherwise create a new one."
  type        = string
  default     = "RTBFabricEKSDiscoveryRole"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_+=,.@-]{0,63}$", var.rtbfabric_eks_discovery_role_name))
    error_message = "Role name must be 1-64 characters, start with a letter, and contain only alphanumeric characters and _+=,.@-"
  }
}

variable "rtbfabric_asg_discovery_role_name" {
  description = "Name for the RTB Fabric ASG Discovery Role (created when asg_discovery_role is not provided). The module will use an existing role with this name if found, otherwise create a new one."
  type        = string
  default     = "RTBFabricAsgDiscoveryRole"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_+=,.@-]{0,63}$", var.rtbfabric_asg_discovery_role_name))
    error_message = "Role name must be 1-64 characters, start with a letter, and contain only alphanumeric characters and _+=,.@-"
  }
}

variable "link" {
  description = "RTB Fabric link configuration with GA schema support and advanced module configuration options"
  type = object({
    create                 = optional(bool, false)
    gateway_id             = optional(string)
    peer_gateway_id        = optional(string)
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
    # New GA schema feature
    module_configuration_list = optional(list(object({
      name       = string
      version    = optional(string)
      depends_on = optional(list(string))
      module_parameters = optional(object({
        no_bid = optional(object({
          reason                  = optional(string)
          reason_code             = optional(number)
          pass_through_percentage = optional(number)
        }))
        open_rtb_attribute = optional(object({
          filter_type = string
          filter_configuration = list(object({
            criteria = list(object({
              path   = string
              values = list(string)
            }))
          }))
          action = object({
            no_bid = optional(object({
              no_bid_reason_code = optional(number)
            }))
            header_tag = optional(object({
              name  = string
              value = string
            }))
          })
          holdback_percentage = number
        }))
      }))
    })))
    tags = optional(list(object({
      key   = string
      value = string
    })), [])
  })
  default = {}

  validation {
    condition     = var.link.gateway_id == null || can(regex("^rtb-gw-[a-z0-9-]{1,25}$", var.link.gateway_id))
    error_message = "Gateway ID must match pattern ^rtb-gw-[a-z0-9-]{1,25}$."
  }

  validation {
    condition     = var.link.peer_gateway_id == null || can(regex("^rtb-gw-[a-z0-9-]{1,25}$", var.link.peer_gateway_id))
    error_message = "Peer Gateway ID must match pattern ^rtb-gw-[a-z0-9-]{1,25}$."
  }

  validation {
    condition     = var.link.tags == null || length(var.link.tags) <= 50
    error_message = "Maximum of 50 tags allowed."
  }

  validation {
    condition = !var.link.create || (
      var.link.gateway_id != null &&
      var.link.peer_gateway_id != null
    )
    error_message = "When create is true, gateway_id and peer_gateway_id are required."
  }
}
