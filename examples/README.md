# Terraform AWS RTB Fabric Examples

This directory contains examples demonstrating different use cases for the RTB Fabric module using the GA (Generally Available) API.

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS Cloud Control API provider (awscc) >= 0.70.0

## Examples

### Requester Gateway
```bash
cd requester-app/
terraform init
terraform plan
terraform apply
```

### Responder Gateway - Basic
```bash
cd responder-app-basic/
terraform init
terraform plan
terraform apply
```

### Responder Gateway with EKS Endpoints
```bash
cd responder-app-eks/
terraform init
terraform plan
terraform apply
```

### Responder Gateway with Auto Scaling Groups
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

### End-to-End Testing
```bash
cd e2e-test/
terraform init
terraform plan
terraform apply
```

## Configuration

Before running any example, update the following values in the respective `main.tf` files:

- `vpc_id` - Your VPC ID
- `subnet_ids` - Your subnet IDs
- `security_group_ids` - Your security group IDs
- `rtb_app_id` and `peer_rtb_app_id` (for link examples) - Existing RTB gateway IDs (format: `rtb-gw-*`)

## Key Changes in GA Version

- **Resource Types**: `RequesterRtbApp` → `RequesterGateway`, `ResponderRtbApp` → `ResponderGateway`
- **ID Format**: Gateway IDs now use `rtb-gw-*` format instead of `rtbapp-*`
- **DNS Name**: No longer an input parameter - now read-only as `domain_name`
- **Certificate Configuration**: `ca_certificate_chain` now maps to `trust_store_configuration`
- **Target Groups**: `target_groups_configuration` removed - use `auto_scaling_groups_configuration` or `eks_endpoints_configuration`
- **Link Logging**: Restructured from `service_logs`/`analytics_logs` to `application_logs`

## Cleanup

To destroy resources:
```bash
terraform destroy
```