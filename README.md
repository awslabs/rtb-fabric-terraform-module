# Terraform AWS RTB Fabric Module

This module creates AWS RTB Fabric resources using Cloud Control APIs.

## Usage

```hcl
module "rtb_fabric" {
  source = "github.com/shapirov103/terraform-aws-rtb-fabric"

  app_name           = "my-rtb-app"
  description        = "My RTB application"
  vpc_id             = "vpc-xxxxxxxxx"
  subnet_ids         = ["subnet-xxxxxxxxx", "subnet-yyyyyyyyy"]
  security_group_ids = ["sg-xxxxxxxxx"]
  client_token       = "unique-token"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| awscc | >= 0.70.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| app_name | Name of the RTB application | string | yes |
| description | Description of the RTB application | string | yes |
| vpc_id | VPC ID where the RTB application will be deployed | string | yes |
| subnet_ids | List of subnet IDs for the RTB application | list(string) | yes |
| security_group_ids | List of security group IDs for the RTB application | list(string) | yes |
| client_token | Client token for the RTB application | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| app_id | ID of the created RTB application |
| app_arn | ARN of the created RTB application |
