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

- `link_id` - The ID of the created inbound external link
- `link_arn` - The ARN of the created inbound external link
- `link_status` - The status of the link

## Notes

- The inbound external link must be attached to a responder gateway
- External partners will need to configure their side to connect to your gateway
- Link acceptance and activation may be required depending on your RTB Fabric configuration
