# RTB Fabric E2E Test Example

This example creates a complete end-to-end RTB Fabric setup with requester gateway, EKS responder gateway, and a link connecting them.

## Quick Start

1. **Copy the configuration template:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit your configuration:**
   ```bash
   # Edit terraform.tfvars with your cluster names
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

- `requester_cluster_name`: EKS cluster name for the requester gateway
- `responder_cluster_name`: EKS cluster name for the responder gateway

### Optional Variables

- `kubernetes_auth_role_name`: IAM role name for Kubernetes authentication (uses current AWS credentials if not specified)

### Example Configuration

```hcl
# terraform.tfvars
requester_cluster_name = "my-publisher-cluster"
responder_cluster_name = "my-bidder-cluster"
kubernetes_auth_role_name = "MyEKSAccessRole"
```

## What This Example Creates

1. **Requester Gateway**: Connected to your publisher/demand-side cluster
2. **Responder Gateway**: Connected to your bidder/supply-side cluster with EKS managed endpoints
3. **RTB Fabric Link**: Connecting the two gateways with sample configuration
4. **EKS Service Discovery Role**: Custom role for endpoint discovery (auto-created)

## Auto-Discovery

This example automatically discovers networking configuration from both EKS clusters:

### Requirements for Auto-Discovery

**EKS Clusters:**
- Both clusters must exist and be accessible with the specified cluster names
- Your AWS credentials must have `eks:DescribeCluster` permission

**Subnet Tags (Optional):**
- `kubernetes.io/role/internal-elb = 1` (for private subnets used by internal load balancers)
- If no subnets have this tag, you may need to add it to your private subnets

### What Gets Discovered
- **VPCs**: Retrieved directly from both EKS cluster configurations
- **Subnets**: Private subnets in each cluster's VPC tagged with `kubernetes.io/role/internal-elb=1`
- **Security Groups**: Cluster security groups from both EKS cluster configurations

## Application Configuration

The following settings use sensible defaults for E2E testing:

- **Responder Port**: 8090 (HTTP)
- **Endpoint Name**: "bidder-internal"
- **Namespace**: "default"
- **Link Configuration**: Sample error masking and module configuration
- **EKS Service Discovery Role**: Custom naming with E2E prefix

## Authentication

The Kubernetes provider (used for the responder gateway) supports:

1. **Current AWS Credentials** (default): Uses your current AWS CLI/SDK credentials
2. **IAM Role**: Set `kubernetes_auth_role_name` to assume a specific role for EKS access (ARN will be constructed automatically)

## Troubleshooting

### Auto-Discovery Issues

If you see auto-discovery errors for either cluster:

1. Verify both EKS clusters exist and are accessible
2. Ensure subnets have the tag: `kubernetes.io/role/internal-elb = 1`
3. Verify your AWS credentials have EKS permissions for both clusters

### Kubernetes Provider Issues

If you see Kubernetes authentication errors:

1. Verify your AWS credentials can access the responder cluster
2. Check that the responder cluster has API access enabled
3. Consider setting `kubernetes_auth_role_name` if using cross-account or role-based access

## Testing the E2E Setup

After deployment, you can test the RTB Fabric link:

1. Check the gateway status outputs
2. Verify the link is active
3. Send test traffic through the requester gateway
4. Monitor logs and metrics through the configured link settings

## Migration from Hardcoded Values

If you're migrating from a previous version with hardcoded values:

1. The provided `terraform.tfvars` maintains existing functionality
2. Gradually migrate to `terraform.tfvars.example` as a template
3. Update your cluster names and authentication settings as needed

## Cleanup

```bash
terraform destroy
```

**Note**: This will destroy all created resources including gateways and the link.