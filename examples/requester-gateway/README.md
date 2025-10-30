# RTB Fabric Requester Gateway Example

This example creates an RTB Fabric requester gateway with automatic network discovery from an EKS cluster.

## Quick Start

1. **Copy the configuration template:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit your configuration:**
   ```bash
   # Edit terraform.tfvars with your cluster name
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

- `cluster_name`: Your EKS cluster name (used for network auto-discovery)

### Example Configuration

```hcl
# terraform.tfvars
cluster_name = "my-publisher-cluster"
```

## Auto-Discovery

This example automatically discovers networking configuration from your EKS cluster:

### Requirements for Auto-Discovery

**EKS Cluster:**
- Must exist and be accessible with the specified cluster name
- Your AWS credentials must have `eks:DescribeCluster` permission

**Subnet Tags (Optional):**
- `kubernetes.io/role/internal-elb = 1` (for private subnets used by internal load balancers)
- If no subnets have this tag, you may need to add it to your private subnets

### What Gets Discovered
- **VPC**: Retrieved directly from EKS cluster configuration
- **Subnets**: Private subnets in the cluster's VPC tagged with `kubernetes.io/role/internal-elb=1`
- **Security Group**: Cluster security group from EKS cluster configuration

No Kubernetes provider authentication is needed for requester gateways.

## Application Configuration

The following settings use sensible defaults and don't need configuration:

- **Environment**: "Prod"
- **Description**: Generated from cluster name

## Troubleshooting

### Auto-Discovery Issues

If you see auto-discovery errors:

1. Verify your EKS cluster exists and is accessible
2. Check that your VPC has the tag: `kubernetes.io/cluster/<cluster_name> = owned` or `shared`
3. Ensure subnets have the tag: `kubernetes.io/role/internal-elb = 1`
4. Verify your AWS credentials have EKS permissions

### Alternative Solutions

If auto-discovery doesn't work for your setup, you may need to create a custom example with manual network configuration similar to `responder-gateway-basic`.

## Migration from Hardcoded Values

If you're migrating from a previous version with hardcoded values:

1. The provided `terraform.tfvars` maintains existing functionality
2. Gradually migrate to `terraform.tfvars.example` as a template
3. Update your cluster name as needed

## Cleanup

```bash
terraform destroy
```