# Complete RTB Fabric Setup Example

Creates a complete RTB Fabric setup with requester app, responder app, and a link connecting them.

## Usage

1. Update `main.tf` with your AWS resource IDs
2. Run:
```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

- 1 RTB Fabric Requester App
- 1 RTB Fabric Responder App  
- 1 RTB Fabric Link connecting the apps

## Note

The link uses module outputs to automatically reference the created apps.