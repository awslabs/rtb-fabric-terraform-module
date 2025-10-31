# RTB Fabric Responder Gateway EKS Hybrid Example

This example creates an RTB Fabric responder gateway with EKS managed endpoints using a custom IAM role creation approach.

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

- `cluster_name`: Your EKS cluster name

### Optional Variables

- `kubernetes_auth_role_name`: IAM role name for Kubernetes authentication (uses current AWS credentials if not specified)

### Example Configuration

```hcl
# terraform.tfvars
cluster_name = "my-bidder-cluster"
kubernetes_auth_role_name = "MyEKSAccessRole"
```

## What Makes This "Hybrid"

This example demonstrates a hybrid approach to IAM role management:

1. **Custom Role Creation**: Creates its own RTB Fabric EKS Service Discovery Role
2. **Custom Naming**: Uses "MyCompany-RTBFabric-EKS-Role" instead of default naming
3. **Custom Tags**: Applies custom tags for enterprise environments
4. **Auto-Discovery**: Still uses EKS cluster auto-discovery for networking
5. **Automatic Integration**: Module still handles policy attachment and EKS access

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

## IAM Role Management

The example creates a custom IAM role with:

- **Custom Name**: "MyCompany-RTBFabric-EKS-Role"
- **Proper Trust Policy**: For RTB Fabric services
- **Custom Tags**: Environment, Purpose, Example tags
- **Automatic Integration**: Module handles policy attachment

## Application Configuration

The following settings use sensible defaults:

- **Port**: 8080 (HTTP)
- **Endpoint Name**: "bidder"
- **Namespace**: "default"
- **Protocol**: HTTP
- **Environment**: "Staging"

## Authentication

The example supports two authentication modes:

1. **Current AWS Credentials** (default): Uses your current AWS CLI/SDK credentials
2. **IAM Role**: Set `kubernetes_auth_role_name` to assume a specific role for EKS access (ARN will be constructed automatically)

## When to Use This Example

This example is suitable when:

- You need custom IAM role naming for enterprise compliance
- You want to apply custom tags to IAM resources
- You need a hybrid approach between full automation and manual control
- You want to understand how custom role creation works with RTB Fabric

## Troubleshooting

### Auto-Discovery Issues

If you see auto-discovery errors:

1. Verify your EKS cluster exists and is accessible
2. Ensure subnets have the tag: `kubernetes.io/role/internal-elb = 1`
3. Verify your AWS credentials have EKS permissions

### IAM Role Issues

If you see IAM-related errors:

1. Verify your AWS credentials have IAM permissions to create roles
2. Check that the role name doesn't conflict with existing roles
3. Ensure your account has permission to create RTB Fabric service roles

### Alternative Solutions

If this hybrid approach doesn't fit your needs:

- `responder-gateway-eks`: Fully automated role creation
- `responder-gateway-basic`: Manual network configuration
- `responder-gateway-asg`: Auto Scaling Group endpoints

## Migration from Hardcoded Values

If you're migrating from a previous version with hardcoded values:

1. The provided `terraform.tfvars` maintains existing functionality
2. Gradually migrate to `terraform.tfvars.example` as a template
3. Update your cluster name and authentication settings as needed

## Cleanup

```bash
terraform destroy
```

**Note**: This will destroy the gateway and the custom IAM role.