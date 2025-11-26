# Inbound External Link Example

This example demonstrates how to create an RTB Fabric Inbound External Link for accepting connections from external RTB Fabric gateways.

## What is an Inbound External Link?

An Inbound External Link allows your responder gateway to accept connections from external RTB Fabric gateways (typically from partners or third-party systems). This is different from a regular link which connects two gateways within your control.

## Prerequisites

- An existing RTB Fabric responder gateway
- The gateway ID of your responder gateway

## Usage

1. Copy the example tfvars file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your values:
```hcl
gateway_id           = "rtb-gw-xxxxxxxxxxxxx"  # Your responder gateway ID
customer_provided_id = "my-external-partner-link"
```

3. Initialize and apply:
```bash
terraform init
terraform plan
terraform apply
```

## Configuration Options

### Link Log Settings

Control the sampling rate for error and filter logs:

```hcl
link_log_settings = {
  error_log  = 10  # 10% of error logs
  filter_log = 5   # 5% of filter logs
}
```

### Responder Error Masking

Configure how HTTP errors are handled and logged:

```hcl
responder_error_masking = [
  {
    http_code                   = "400"
    action                      = "NO_BID"
    logging_types               = ["METRIC", "RESPONSE"]
    response_logging_percentage = 15.0
  }
]
```

**Available Actions:**
- `NO_BID` - Return a no-bid response
- Other actions as supported by RTB Fabric

**Logging Types:**
- `METRIC` - Log metrics
- `RESPONSE` - Log responses
- `REQUEST` - Log requests

### Tags

Tags use the standard Terraform map format:

```hcl
tags = {
  Environment = "Production"
  LinkType    = "External"
  Partner     = "CompanyName"
}
```

## Outputs

- `link_id` - The link ID of the created inbound external link
- `link_arn` - The ARN of the created inbound external link
- `link_status` - The status of the link (e.g., ACTIVE, PENDING)
- `gateway_id` - The gateway ID that the link is attached to
- `created_timestamp` - When the link was created
- `updated_timestamp` - When the link was last updated

## How External Partners Connect

The inbound external link itself doesn't provide a connection URL. Instead:

1. **Your responder gateway** has a `domain_name` that external partners use to connect
2. The **inbound external link** configures how your gateway accepts those connections
3. Share your gateway's domain name with external partners

**Example workflow:**
```hcl
# 1. Create responder gateway (or reference existing one)
module "responder" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"
  responder_gateway = {
    create = true
    # ... configuration
  }
}

# 2. Create inbound external link
module "external_link" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"
  inbound_external_link = {
    create     = true
    gateway_id = module.responder.responder_gateway_id
    # ... configuration
  }
}

# 3. Share this domain with external partners
output "partner_connection_url" {
  value = module.responder.responder_gateway_domain_name
}
```

## Notes

- The inbound external link must be attached to a responder gateway
- External partners connect to your **gateway's domain name**, not the link
- The link configures error handling, logging, and other connection policies
- Link acceptance and activation may be required depending on your RTB Fabric configuration
