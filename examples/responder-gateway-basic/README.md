# RTB Fabric Responder Gateway Basic Example

This example creates an RTB Fabric responder gateway with manual network configuration and a custom domain name.

## Quick Start

1. **Copy the configuration template:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit your configuration:**
   ```bash
   # Edit terraform.tfvars with your network settings
   vim terraform.tfvars
   ```

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

- `vpc_id`: VPC ID where the gateway will be deployed
- `subnet_ids`: List of subnet IDs for the gateway
- `security_group_ids`: List of security group IDs for the gateway
- `domain_name`: Domain name for the gateway (e.g., load balancer DNS name)

### Example Configuration

```hcl
# terraform.tfvars
vpc_id = "vpc-01234567890abcdef"
subnet_ids = ["subnet-01234567890abcdef", "subnet-fedcba0987654321"]
security_group_ids = ["sg-01234567890abcdef"]
domain_name = "my-load-balancer.elb.us-east-1.amazonaws.com"
```

## When to Use This Example

This example is suitable when:

- You want full control over network configuration
- Your infrastructure doesn't follow EKS cluster tagging conventions
- You're not using EKS or want to specify networking manually
- You have a custom load balancer setup

## Application Configuration

The following settings use sensible defaults:

- **Port**: 31234 (HTTP)
- **Protocol**: HTTP
- **Environment**: "Test"

## Network Requirements

Ensure your network configuration meets these requirements:

- **VPC**: Must exist and be accessible
- **Subnets**: Should be private subnets suitable for internal load balancers
- **Security Groups**: Must allow inbound traffic on the configured port (31234)
- **Domain Name**: Should point to a load balancer or service in your network

## Validation

The example includes validation for:

- Valid AWS VPC ID format (`vpc-xxxxxxxx`)
- Valid AWS subnet ID format (`subnet-xxxxxxxx`)
- Valid AWS security group ID format (`sg-xxxxxxxx`)
- Non-empty domain name

## Troubleshooting

### Network Configuration Issues

If you see deployment errors:

1. Verify all resource IDs exist and are accessible
2. Check that subnets are in the specified VPC
3. Ensure security groups allow the required traffic
4. Verify the domain name resolves correctly

### Alternative Solutions

If you prefer automatic network discovery:

- `responder-gateway-eks`: Auto-discovery from EKS cluster tags
- `responder-gateway-asg`: Auto Scaling Group endpoints with manual networking

## Migration from Hardcoded Values

If you're migrating from a previous version with hardcoded values:

1. The provided `terraform.tfvars` maintains existing functionality
2. Gradually migrate to `terraform.tfvars.example` as a template
3. Update your network configuration as needed

## Cleanup

```bash
terraform destroy
```