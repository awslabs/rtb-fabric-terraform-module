variable "requester_gateway" {
  description = "Requester RTB Fabric gateway configuration for GA schema"
  type = object({
    create             = optional(bool, false)
    description        = optional(string)
    vpc_id             = optional(string)
    subnet_ids         = optional(list(string))
    security_group_ids = optional(list(string))
    tags               = optional(map(string), {})
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
    condition     = var.requester_gateway.tags == null || length(keys(var.requester_gateway.tags)) <= 50
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
    domain_name        = optional(string) # GA API field name - domain name for the responder gateway
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
        auto_create_access         = optional(bool, true)
        auto_create_rbac           = optional(bool, true)
        auto_create_role           = optional(bool, true) # Controls whether to create the eks_service_discovery_role or assume it exists
      }))
    }))
    tags = optional(map(string), {})
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
    condition     = var.responder_gateway.domain_name == null || can(regex("^(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)(?:\\.(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?))+$", var.responder_gateway.domain_name))
    error_message = "domain_name must be a valid domain name format."
  }

  validation {
    condition = var.responder_gateway.trust_store_configuration == null || (
      var.responder_gateway.trust_store_configuration.certificate_authority_certificates != null &&
      length(var.responder_gateway.trust_store_configuration.certificate_authority_certificates) > 0
    )
    error_message = "trust_store_configuration.certificate_authority_certificates must contain at least one certificate."
  }

  validation {
    condition     = var.responder_gateway.tags == null || length(keys(var.responder_gateway.tags)) <= 50
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
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_role == null ||
      can(tobool(var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_role))
    )
    error_message = "auto_create_role must be a boolean value (true or false)"
  }

  validation {
    condition = (
      var.responder_gateway.managed_endpoint_configuration == null ||
      var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration == null ||
      (
        var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_scaling_group_name_list != null &&
        length(var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_scaling_group_name_list) > 0
      )
    )
    error_message = "auto_scaling_group_name_list is required and must contain at least one Auto Scaling Group name when using ASG endpoints configuration."
  }

  validation {
    condition = (
      var.responder_gateway.managed_endpoint_configuration == null ||
      var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration == null ||
      var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role == null ||
      can(regex("^[a-zA-Z][a-zA-Z0-9_+=,.@-]{0,63}$", var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role))
    )
    error_message = "asg_discovery_role must be a valid IAM role name (1-64 characters, start with letter, alphanumeric and _+=,.@- allowed)"
  }

  validation {
    condition = (
      var.responder_gateway.managed_endpoint_configuration == null ||
      var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration == null ||
      var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_create_role == null ||
      can(tobool(var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_create_role))
    )
    error_message = "auto_create_role must be a boolean value (true or false)"
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
      application_logs = object({
        link_application_log_sampling = object({
          error_log  = number
          filter_log = number
        })
      })
    }))
    # GA schema ModuleConfigurationList - matches AWS schema directly
    module_configuration_list = optional(list(object({
      name       = string
      version    = optional(string)
      depends_on = optional(list(string))
      module_parameters = optional(object({
        # OneOf: either no_bid OR open_rtb_attribute
        no_bid = optional(object({
          reason                  = optional(string)
          reason_code             = optional(number)
          pass_through_percentage = optional(number)
        }))
        open_rtb_attribute = optional(object({
          filter_type = optional(string)
          filter_configuration = optional(list(object({
            criteria = optional(list(object({
              path   = optional(string)
              values = optional(list(string))
            })))
          })))
          action = optional(object({
            # OneOf: either no_bid OR header_tag
            no_bid = optional(object({
              no_bid_reason_code = optional(number)
            }))
            header_tag = optional(object({
              name  = optional(string)
              value = optional(string)
            }))
          }))
          holdback_percentage = optional(number)
        }))
      }))
    })))
    tags = optional(map(string), {})
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
    condition     = var.link.tags == null || length(keys(var.link.tags)) <= 50
    error_message = "Maximum of 50 tags allowed."
  }

  validation {
    condition = !var.link.create || (
      var.link.gateway_id != null &&
      var.link.peer_gateway_id != null
    )
    error_message = "When create is true, gateway_id and peer_gateway_id are required."
  }

  # validation {
  #   condition     = !var.link.create || var.link.link_log_settings != null
  #   error_message = "LinkLogSettings is required when creating a link."
  # }

  validation {
    condition = var.link.link_log_settings == null || (
      var.link.link_log_settings.application_logs.link_application_log_sampling.error_log >= 0 &&
      var.link.link_log_settings.application_logs.link_application_log_sampling.error_log <= 100 &&
      var.link.link_log_settings.application_logs.link_application_log_sampling.filter_log >= 0 &&
      var.link.link_log_settings.application_logs.link_application_log_sampling.filter_log <= 100
    )
    error_message = "ErrorLog and FilterLog must be between 0 and 100."
  }

  validation {
    condition     = var.link.link_attributes == null || var.link.link_attributes.responder_error_masking == null || length(var.link.link_attributes.responder_error_masking) <= 200
    error_message = "Maximum of 200 responder error masking rules allowed."
  }

  validation {
    condition     = var.link.module_configuration_list == null || length(var.link.module_configuration_list) >= 0
    error_message = "ModuleConfigurationList must be a valid list."
  }

  validation {
    condition = var.link.module_configuration_list == null || alltrue([
      for module in var.link.module_configuration_list :
      module.module_parameters == null || (
        (module.module_parameters.no_bid != null && module.module_parameters.open_rtb_attribute == null) ||
        (module.module_parameters.no_bid == null && module.module_parameters.open_rtb_attribute != null)
      )
    ])
    error_message = "module_parameters must contain either 'no_bid' OR 'open_rtb_attribute', not both."
  }

  validation {
    condition = var.link.module_configuration_list == null || alltrue([
      for module in var.link.module_configuration_list :
      module.module_parameters == null ||
      module.module_parameters.open_rtb_attribute == null ||
      module.module_parameters.open_rtb_attribute.action == null ||
      (module.module_parameters.open_rtb_attribute.action.no_bid != null || module.module_parameters.open_rtb_attribute.action.header_tag != null)
    ])
    error_message = "When using open_rtb_attribute, action must contain either 'no_bid' or 'header_tag'."
  }

  validation {
    condition = var.link.module_configuration_list == null || length([
      for name in [for m in var.link.module_configuration_list : m.name] : name
      if length([for n in [for m in var.link.module_configuration_list : m.name] : n if n == name]) > 1
    ]) == 0
    error_message = "Module names must be unique within the module_configuration_list."
  }
}

variable "inbound_external_link" {
  description = "Inbound External Link configuration for accepting connections from external RTB Fabric gateways"
  type = object({
    create     = optional(bool, false)
    gateway_id = optional(string)
    link_log_settings = optional(object({
      error_log  = number
      filter_log = number
    }))
    link_attributes = optional(object({
      customer_provided_id = optional(string)
      responder_error_masking = optional(list(object({
        action                      = optional(string)
        http_code                   = optional(string)
        logging_types               = optional(set(string))
        response_logging_percentage = optional(number)
      })))
    }))
    tags = optional(map(string), {})
  })
  default = {}

  validation {
    condition     = var.inbound_external_link.gateway_id == null || can(regex("^rtb-gw-[a-z0-9-]{1,25}$", var.inbound_external_link.gateway_id))
    error_message = "Gateway ID must match pattern ^rtb-gw-[a-z0-9-]{1,25}$."
  }

  validation {
    condition     = var.inbound_external_link.tags == null || length(keys(var.inbound_external_link.tags)) <= 50
    error_message = "Maximum of 50 tags allowed."
  }

  validation {
    condition = !var.inbound_external_link.create || (
      var.inbound_external_link.gateway_id != null &&
      var.inbound_external_link.link_log_settings != null
    )
    error_message = "When create is true, gateway_id and link_log_settings are required."
  }

  validation {
    condition = var.inbound_external_link.link_log_settings == null || (
      var.inbound_external_link.link_log_settings.error_log >= 0 &&
      var.inbound_external_link.link_log_settings.error_log <= 100 &&
      var.inbound_external_link.link_log_settings.filter_log >= 0 &&
      var.inbound_external_link.link_log_settings.filter_log <= 100
    )
    error_message = "Log sampling percentages must be between 0 and 100."
  }
}
