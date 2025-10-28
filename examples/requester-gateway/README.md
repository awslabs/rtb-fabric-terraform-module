# RTB Fabric Requester Gateway with EKS Cluster Discovery

This example demonstrates how to create an RTB Fabric requester gateway using **automatic resource discovery** based on an EKS cluster name.

## How It Works

Instead of manually specifying VPC, subnets, and security groups, this example:

1. **Takes a cluster name** as input variable
2. **Discovers the VPC** tagged with `kubernetes.io/cluster/<cluster_name>` (supports both "owned" and "shared" values)
3. **Discovers private subnets** in that VPC with the same cluster tag and names starting with "Private"
4. **Gets the cluster security group** from the EKS cluster configuration
5. **Uses these discovered resources** for the requester gateway

## Prerequisites

Your EKS cluster must have the standard Kubernetes tags:
- **VPC**: Tagged with `kubernetes.io/cluster/<cluster_name>` = "owned" or "shared"
- **Private Subnets**: Tagged with `kubernetes.io/cluster/<cluster_name>` = "owned" or "shared" AND named starting with "Private" (e.g., "PrivateSubnet1", "PrivateSubnet2")
- **EKS Cluster**: Must exist and be accessible

These tags are automatically created by EKS when you create a cluster. The "owned" value means the cluster manages the resource lifecycle, while "shared" means multiple clusters can use the resource.

## Usage

### Option 1: Use Default Cluster Name
```bash
terraform init
terraform plan
terraform apply
```
This uses the default cluster name `my-eks-cluster`.

### Option 2: Specify Your Cluster Name
```bash
terraform init
terraform plan -var="cluster_name=your-cluster-name"
terraform apply -var="cluster_name=your-cluster-name"
```

### Option 3: Use terraform.tfvars
Create a `terraform.tfvars` file:
```hcl
cluster_name = "production-eks-cluster"
```

Then run:
```bash
terraform init
terraform plan
terraform apply
```

## What Gets Created

- **RTB Fabric Requester Gateway** in the discovered VPC and subnets
- **Automatic tagging** with cluster name for easy identification

## Outputs

The example provides outputs showing what was discovered:
```bash
terraform output discovered_vpc_id
terraform output discovered_private_subnet_ids
terraform output discovered_security_group_id
terraform output cluster_name_used
```

## Benefits

- **Simplified Configuration**: Just provide cluster name instead of multiple resource IDs
- **Automatic Discovery**: No need to manually look up VPC/subnet/security group IDs
- **Consistent with EKS**: Uses the same networking resources as your EKS cluster
- **Reduced Errors**: Eliminates manual ID copy/paste mistakes
- **Environment Agnostic**: Works across different AWS accounts/regions

## Example Output

```
discovered_vpc_id = "vpc-0123456789abcdef0"
discovered_private_subnet_ids = [
  "subnet-0123456789abcdef0",  # PrivateSubnet1
  "subnet-0987654321fedcba0",  # PrivateSubnet2
  "subnet-0abcdef123456789"    # PrivateSubnet3
]
discovered_security_group_id = "sg-0123456789abcdef0"
cluster_name_used = "my-production-cluster"
```

## Tag Value Support

The discovery supports both EKS tagging patterns:
- **"owned"**: Cluster manages the resource lifecycle (typical for cluster-specific VPCs)
- **"shared"**: Resource is shared between multiple clusters (common in enterprise environments)

## Private Subnet Filtering

Only subnets with names starting with "Private" are selected, ensuring the requester gateway is deployed in private subnets for security best practices.

This approach makes it much easier to deploy RTB Fabric gateways that integrate with existing EKS infrastructure!