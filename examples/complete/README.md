# Complete RTB Fabric Setup Example

Creates a complete RTB Fabric setup with requester gateway, responder gateway, and a link connecting them using the GA API.

## Usage

1. Update `main.tf` with your AWS resource IDs
2. Run:
```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

- 1 RTB Fabric Requester Gateway
- 1 RTB Fabric Responder Gateway
- 1 RTB Fabric Link connecting the gateways

## Key Features

- Uses GA API resource types (`RequesterGateway`, `ResponderGateway`)
- Demonstrates proper link log settings configuration
- The link uses module outputs to automatically reference the created gateways
- Shows certificate configuration using `trust_store_configuration`

## Outputs

- Gateway IDs, ARNs, and domain names
- Link status and metadata