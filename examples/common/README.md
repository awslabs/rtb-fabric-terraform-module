# EKS Cluster Discovery Module

This shared module provides reusable EKS cluster discovery logic for RTB Fabric examples.

## What it does

Given an EKS cluster name, this module automatically discovers:
- **VPC ID** - from `kubernetes.io/cluster/<cluster_name>` tags
- **Subnet IDs** - all subnets in the VPC tagged with the cluster
- **Security Group ID** - the cluster's primary security group

## Usage

```hcl
module "cluster_discovery" {
  source = "../common"
  cluster_name = var.cluster_name
}

module "rtb_fabric" {
  source = "../../"
  
  requester_gateway = {
    vpc_id             = module.cluster_discovery.discovered_vpc_id
    subnet_ids         = module.cluster_discovery.discovered_private_subnet_ids
    security_group_ids = [module.cluster_discovery.discovered_security_group_id]
    # ... other configuration
  }
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| cluster_name | Name of the EKS cluster to discover resources from | `string` | n/a |

## Outputs

| Name | Description |
|------|-------------|
| discovered_vpc_id | VPC ID discovered from cluster tags |
| discovered_private_subnet_ids | List of subnet IDs discovered from cluster tags |
| discovered_security_group_id | Security group ID from EKS cluster |
| cluster_name_used | Cluster name used for resource discovery |

## Requirements

- EKS cluster must exist and be accessible
- VPC must be tagged with:
  - `kubernetes.io/cluster/<cluster_name>` = `owned` or `shared`
  - `kubernetes.io/role/internal-elb` = `1` (for private subnet support)
- Private subnets must be tagged with:
  - `kubernetes.io/cluster/<cluster_name>` = `owned` or `shared`
  - `kubernetes.io/role/internal-elb` = `1` (identifies private subnets)
- AWS provider must have permissions to describe EKS clusters, VPCs, and subnets

## Examples using this module

- `examples/requester-gateway/` - Requester gateway with cluster discovery
- `examples/responder-gateway-eks/` - Responder gateway with cluster discovery
- `examples/responder-gateway-eks-hybrid/` - Hybrid setup with cluster discovery
- `examples/responder-gateway-eks-manual/` - Manual setup with cluster discovery