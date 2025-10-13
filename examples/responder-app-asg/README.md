# Responder App with Auto Scaling Groups Example

Creates an RTB Fabric responder application with Auto Scaling Groups configuration.

## Prerequisites

- Existing Auto Scaling Groups
- IAM role with ASG permissions

## Usage

1. Update `main.tf` with your:
   - AWS resource IDs
   - Auto Scaling Group names
   - IAM role ARN
2. Run:
```bash
terraform init
terraform plan
terraform apply

# View outputs after deployment
terraform output

# Get specific output
terraform output responder_app_id
```

## Resources Created

- 1 RTB Fabric Responder App with ASG endpoints