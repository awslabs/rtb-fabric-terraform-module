# Terraform AWS RTB Fabric Examples

This directory contains examples demonstrating different use cases for the RTB Fabric module.

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS Cloud Control API provider (awscc) >= 0.70.0

## Examples

### Basic Requester App
```bash
cd basic/
terraform init
terraform plan
terraform apply
```

### Requester App with Tags
```bash
cd requester-app/
terraform init
terraform plan
terraform apply
```

### Responder App with EKS Endpoints
```bash
cd responder-app-eks/
terraform init
terraform plan
terraform apply
```

### Responder App with Auto Scaling Groups
```bash
cd responder-app-asg/
terraform init
terraform plan
terraform apply
```

### RTB Fabric Link
```bash
cd link/
terraform init
terraform plan
terraform apply
```

### Complete Setup (All Resources)
```bash
cd complete/
terraform init
terraform plan
terraform apply
```

## Configuration

Before running any example, update the following values in the respective `main.tf` files:

- `vpc_id` - Your VPC ID
- `subnet_ids` - Your subnet IDs
- `security_group_ids` - Your security group IDs
- `rtb_app_id` and `peer_rtb_app_id` (for link examples) - Existing RTB app IDs

## Cleanup

To destroy resources:
```bash
terraform destroy
```