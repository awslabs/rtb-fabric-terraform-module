# RTB Fabric Link Example

Creates an RTB Fabric link between existing RTB applications with full configuration including error masking and logging settings.

## Prerequisites

- Existing RTB Fabric requester and responder applications

## Usage

1. Update `main.tf` with your existing RTB app IDs
2. Run:
```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

- 1 RTB Fabric Link with advanced configuration