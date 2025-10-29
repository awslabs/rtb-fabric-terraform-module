# Responder Gateway with Auto Scaling Groups Example

Creates an RTB Fabric responder gateway with Auto Scaling Groups configuration using automatic role creation.

## Overview

This example demonstrates the **automatic setup** approach for ASG managed endpoints. The module will automatically create an ASG discovery role (`RTBFabricAsgDiscoveryRole`) with the proper trust policy and permissions for RTB Fabric service access.

## Prerequisites

- Existing Auto Scaling Groups
- VPC, subnets, and security groups for the responder gateway

## Configuration Approaches

### Automatic Setup (This Example)
The module creates and configures the ASG discovery role automatically:
- Creates `RTBFabricAsgDiscoveryRole` (or custom name)
- Configures trust policy with RTB Fabric service principals
- Attaches ASG and EC2 discovery permissions with region restrictions

### Manual Setup (Alternative)
For pre-configured roles, set:
```hcl
auto_scaling_groups_configuration = {
  auto_scaling_group_name_list = ["my-asg-1", "my-asg-2"]
  asg_discovery_role          = "MyExistingRole"
  auto_create_role            = false
}
```

## Required Trust Policy (Manual Setup)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "rtbfabric.amazonaws.com",
          "rtbfabric-endpoints.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## Required Permissions (Manual Setup)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AsgEndpointsIpDiscovery",
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInstances",
        "ec2:DescribeAvailabilityZones"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:Region": "us-east-1"
        }
      }
    }
  ]
}
```

## Usage

1. Update `main.tf` with your:
   - VPC ID, subnet IDs, and security group IDs
   - Auto Scaling Group names
   - Optional: Custom role name for enterprise naming conventions

2. Run:
```bash
terraform init
terraform plan
terraform apply

# View outputs after deployment
terraform output

# Get specific output
terraform output responder_gateway_id
```

## Resources Created

- 1 RTB Fabric Responder Gateway with ASG endpoints
- 1 IAM Role for ASG discovery (RTBFabricAsgDiscoveryRole)
- 1 IAM Policy with ASG and EC2 permissions