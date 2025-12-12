# Inbound External Link Feature

## Overview

Version 0.3.0 adds support for RTB Fabric Inbound External Links, enabling responder gateways to accept connections from external RTB Fabric gateways.

## What's an Inbound External Link?

An Inbound External Link allows your responder gateway to receive connections from external partners or third-party RTB Fabric gateways. This is different from a regular link which connects two gateways you control.

## Key Differences from Regular Links

| Feature | Regular Link | Inbound External Link |
|---------|-------------|----------------------|
| **Purpose** | Connect your own gateways | Accept external connections |
| **Gateway Types** | Requester ↔ Responder | External → Your Responder |
| **Control** | Full control of both sides | You control only your side |
| **Use Case** | Internal traffic routing | Partner integrations |

## Configuration

### Basic Example

```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module?ref=v0.3.0"

  inbound_external_link = {
    create     = true
    gateway_id = "rtb-gw-abc123"  # Your responder gateway
    
    link_log_settings = {
      error_log  = 10  # 10% sampling
      filter_log = 5   # 5% sampling
    }
    
    tags = {
      Environment = "Production"
      Partner     = "ExternalCompany"
    }
  }
}
```

### Advanced Configuration with Error Masking

```hcl
inbound_external_link = {
  create     = true
  gateway_id = "rtb-gw-abc123"
  
  link_log_settings = {
    error_log  = 10
    filter_log = 5
  }
  
  link_attributes = {
    customer_provided_id = "partner-xyz-link"
    
    responder_error_masking = [
      {
        http_code                   = "400"
        action                      = "NO_BID"
        logging_types               = ["METRIC", "RESPONSE"]
        response_logging_percentage = 15.0
      },
      {
        http_code                   = "500"
        action                      = "NO_BID"
        logging_types               = ["METRIC"]
        response_logging_percentage = 25.0
      }
    ]
  }
  
  tags = {
    Environment = "Production"
    LinkType    = "External"
    Partner     = "CompanyXYZ"
  }
}
```

## Configuration Options

### Required Fields

- `create` - Set to `true` to create the resource
- `gateway_id` - Your responder gateway ID (format: `rtb-gw-xxxxx`)
- `link_log_settings` - Log sampling configuration
  - `error_log` - Error log sampling percentage (0-100)
  - `filter_log` - Filter log sampling percentage (0-100)

### Optional Fields

- `link_attributes` - Additional link configuration
  - `customer_provided_id` - Custom identifier for the link
  - `responder_error_masking` - Error handling rules (list)
    - `http_code` - HTTP status code to mask
    - `action` - Action to take (e.g., "NO_BID")
    - `logging_types` - Types of logs to capture (["METRIC", "RESPONSE", "REQUEST"])
    - `response_logging_percentage` - Percentage of responses to log (0-100)
- `tags` - Resource tags (map format)

## Outputs

The module provides these outputs for inbound external links:

- `inbound_external_link_id` - Link ID
- `inbound_external_link_arn` - Link ARN
- `inbound_external_link_status` - Link status
- `inbound_external_link_gateway_id` - Gateway ID the link is attached to
- `inbound_external_link_created_timestamp` - Creation time
- `inbound_external_link_updated_timestamp` - Last update time

**Note:** The connection URL/domain name comes from the responder gateway, not the link. Use `responder_gateway_domain_name` output to get the URL that external partners should connect to.

## Example Usage

See `examples/inbound-external-link/` for a complete working example.

## Design Decisions

### Simplified Log Settings

Unlike the regular link which uses nested CloudFormation structure, inbound external link uses a flattened structure:

```hcl
# Simplified (Inbound External Link)
link_log_settings = {
  error_log  = 10
  filter_log = 5
}

# vs. Nested (Regular Link)
link_log_settings = {
  application_logs = {
    link_application_log_sampling = {
      error_log  = 10
      filter_log = 5
    }
  }
}
```

### Tag Format

Consistent with v0.2.2+ changes, uses standard Terraform map format:

```hcl
tags = {
  Environment = "Production"
  Partner     = "CompanyName"
}
```

The module automatically converts this to CloudFormation list format internally.

## Migration from CloudFormation

If migrating from CloudFormation, the mapping is:

| CloudFormation | Terraform Module |
|---------------|------------------|
| `GatewayId` | `gateway_id` |
| `LinkLogSettings.ApplicationLogs.LinkApplicationLogSampling.ErrorLog` | `link_log_settings.error_log` |
| `LinkLogSettings.ApplicationLogs.LinkApplicationLogSampling.FilterLog` | `link_log_settings.filter_log` |
| `LinkAttributes.CustomerProvidedId` | `link_attributes.customer_provided_id` |
| `Tags` (list) | `tags` (map) |

## Validation

The module includes validation for:

- Gateway ID format (must match `^rtb-gw-[a-z0-9-]{1,25}$`)
- Log sampling percentages (0-100)
- Maximum 50 tags
- Required fields when `create = true`

## Notes

- The inbound external link must be attached to a responder gateway
- External partners need to configure their side separately
- Link acceptance/activation may be required depending on your setup
- This is a new resource type in v0.3.0 - no breaking changes to existing resources
