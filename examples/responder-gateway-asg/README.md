# RTB Fabric Responder Gateway ASG Example

This example creates an RTB Fabric responder gateway with Auto Scaling Group managed endpoints for automatic instance discovery.

## Quick Start

1. **Copy the configuration template:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit your configuration:**
   ```bash
   # Edit terraform.tfvars with your ASG and network settings
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
- `auto_scaling_group_names`: List of Auto Scaling Group names for endpoint discovery

### Example Configuration

```hcl
# terraform.tfvars
vpc_id = "vpc-01234567890abcdef"
subnet_ids = ["subnet-01234567890abcdef", "subnet-fedcba0987654321"]
security_group_ids = ["sg-01234567890abcdef"]
auto_scaling_group_names = ["my-app-asg-1", "my-app-asg-2"]
```

## How ASG Managed Endpoints Work

This example uses Auto Scaling Groups for managed endpoint discovery:

1. **RTB Fabric Service**: Automatically discovers instances in the specified ASGs
2. **Dynamic Routing**: Routes traffic to healthy instances in the ASGs
3. **Auto-Scaling**: Automatically adapts to ASG scaling events
4. **Health Monitoring**: Only routes to healthy instances

## IAM Role Creation

The module automatically creates the `RTBFabricAsgDiscoveryRole` with:

- Proper trust policy for RTB Fabric services
- Permissions to describe Auto Scaling Groups and EC2 instances
- Automatic attachment to the responder gateway

## Application Configuration

The following settings use sensible defaults:

- **Port**: 31234 (HTTP)
- **Protocol**: HTTP
- **Environment**: "Test"

## Network Requirements

Ensure your configuration meets these requirements:

- **VPC**: Must exist and be accessible
- **Subnets**: Should be private subnets suitable for internal load balancers
- **Security Groups**: Must allow inbound traffic on the configured port (31234)
- **ASGs**: Must exist and contain running instances with your application

## Validation

The example includes validation for:

- Valid AWS VPC ID format (`vpc-xxxxxxxx`)
- Valid AWS subnet ID format (`subnet-xxxxxxxx`)
- Valid AWS security group ID format (`sg-xxxxxxxx`)
- At least one Auto Scaling Group name provided

## Troubleshooting

### ASG Discovery Issues

If you see endpoint discovery errors:

1. Verify all ASG names exist and are accessible
2. Check that ASGs have running, healthy instances
3. Ensure instances are running your application on the expected port
4. Verify the RTBFabricAsgDiscoveryRole has proper permissions

### Network Configuration Issues

If you see deployment errors:

1. Verify all resource IDs exist and are accessible
2. Check that subnets are in the specified VPC
3. Ensure security groups allow the required traffic
4. Verify ASG instances are in the same VPC/subnets

### Alternative Solutions

If ASG discovery doesn't work for your setup:

- `responder-gateway-eks`: EKS managed endpoints with auto-discovery
- `responder-gateway-basic`: Manual configuration with custom domain

## Migration from Hardcoded Values

If you're migrating from a previous version with hardcoded values:

1. The provided `terraform.tfvars` maintains existing functionality
2. Gradually migrate to `terraform.tfvars.example` as a template
3. Update your ASG names and network configuration as needed

## Cleanup

```bash
terraform destroy
```

**Note**: This will destroy the gateway and associated IAM role, but not your Auto Scaling Groups.