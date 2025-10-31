# Terraform AWS RTB Fabric Examples

This directory contains examples demonstrating different use cases for the RTB Fabric module using the GA (Generally Available) API.

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS Cloud Control API provider (awscc) >= 0.70.0

## Examples

### Requester Gateway
```bash
cd requester-gateway/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your cluster name
terraform init
terraform plan
terraform apply
```

### Responder Gateway - Basic
```bash
cd responder-gateway-basic/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your network configuration
terraform init
terraform plan
terraform apply
```

### Responder Gateway with EKS Endpoints
```bash
cd responder-gateway-eks/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your cluster name
terraform init
terraform plan
terraform apply
```

### Responder Gateway with Auto Scaling Groups
```bash
cd responder-gateway-asg/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your ASG and network configuration
terraform init
terraform plan
terraform apply
```

### Responder Gateway EKS Hybrid
```bash
cd responder-gateway-eks-hybrid/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your cluster name
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
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your cluster names
terraform init
terraform plan
terraform apply
```

## Configuration

Each example now uses configurable variables instead of hardcoded values:

### Auto-Discovery Examples (Recommended)
Examples that automatically discover network configuration from EKS clusters:
- `requester-gateway` - Only requires `cluster_name`
- `responder-gateway-eks` - Requires `cluster_name`, optional `kubernetes_auth_role_name`
- `responder-gateway-eks-hybrid` - Requires `cluster_name`, optional `kubernetes_auth_role_name`
- `e2e-test` - Requires `requester_cluster_name` and `responder_cluster_name`

### Manual Configuration Examples
Examples that require explicit network configuration:
- `responder-gateway-basic` - Requires `vpc_id`, `subnet_ids`, `security_group_ids`, `domain_name`
- `responder-gateway-asg` - Requires `vpc_id`, `subnet_ids`, `security_group_ids`, `auto_scaling_group_names`

### Setup Steps
1. Copy the configuration template: `cp terraform.tfvars.example terraform.tfvars`
2. Edit `terraform.tfvars` with your specific values
3. Run: `terraform init && terraform plan && terraform apply`

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