# Terraform AWS RTB Fabric Module

This module creates AWS RTB Fabric resources using Cloud Control APIs. It supports creating:
- Requester RTB Apps
- Responder RTB Apps (with managed EKS endpoints)
- RTB Fabric Links

## Usage Examples

### Requester App Only
```hcl
module "rtb_fabric" {
  source = "github.com/shapirov103/terraform-aws-rtb-fabric"

  requester_app = {
    create             = true
    app_name           = "test02"
    description        = "test02"
    vpc_id             = "vpc-00108ced4ec00636b"
    subnet_ids         = ["subnet-0e656d1ce3ba7d025", "subnet-0efd6f0427bfe0a3b"]
    security_group_ids = ["sg-050ebc8a5303a9337"]
    client_token       = "test02"
    tags = [
      {
        key   = "Environment"
        value = "Production"
      }
    ]
  }
}
```

### Responder App with EKS Endpoints
```hcl
module "rtb_fabric" {
  source = "github.com/shapirov103/terraform-aws-rtb-fabric"

  responder_app = {
    create               = true
    app_name             = "test35"
    description          = "test11"
    vpc_id               = "vpc-00108ced4ec00636b"
    subnet_ids           = ["subnet-0e656d1ce3ba7d025", "subnet-0efd6f0427bfe0a3b"]
    security_group_ids   = ["sg-050ebc8a5303a9337"]
    port                 = 1234
    protocol             = "HTTPS"
    dns_name             = "cloudformation-test-eks-managed.heimdall.dev"
    ca_certificate_chain = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t..."

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name                  = "nginx-deployment"
        endpoints_resource_namespace             = "default"
        cluster_api_server_endpoint_uri          = "https://965DAA609C940C21E50AC0FB7F3EAFE1.gr7.us-east-1.eks.amazonaws.com"
        cluster_api_server_ca_certificate_chain = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t..."
        cluster_name                             = "yimasontestekscluster"
        role_arn                                 = "arn:aws:iam::561605471193:role/Admin"
      }
    }
    
    tags = [
      {
        key   = "testkey"
        value = "testvalue"
      }
    ]
  }
}
```

### Responder App with Auto Scaling Groups
```hcl
module "rtb_fabric" {
  source = "github.com/shapirov103/terraform-aws-rtb-fabric"

  responder_app = {
    create               = true
    app_name             = "asg-responder"
    description          = "ASG responder app"
    vpc_id               = "vpc-00108ced4ec00636b"
    subnet_ids           = ["subnet-0e656d1ce3ba7d025"]
    security_group_ids   = ["sg-050ebc8a5303a9337"]
    port                 = 8080
    protocol             = "HTTP"
    dns_name             = "asg-app.example.com"
    ca_certificate_chain = "LS0tLS..."

    managed_endpoint_configuration = {
      auto_scaling_groups_configuration = {
        auto_scaling_group_name_list = ["my-asg-1", "my-asg-2"]
        role_arn                     = "arn:aws:iam::123456789012:role/ASGRole"
      }
    }
  }
}
```

### RTB Fabric Link
```hcl
module "rtb_fabric" {
  source = "github.com/shapirov103/terraform-aws-rtb-fabric"

  link = {
    create                 = true
    rtb_app_id            = "rtbapp-abc123"
    peer_rtb_app_id       = "rtbapp-def456"
    http_responder_allowed = true
    
    link_attributes = {
      customer_provided_id = "my-custom-id"
      responder_error_masking = [
        {
          http_code     = "4XX"
          action        = "NO_BID"
          logging_types = ["METRIC", "RESPONSE"]
          response_logging_percentage = 10.5
        }
      ]
    }
    
    link_log_settings = {
      service_logs = {
        link_service_log_sampling = {
          error_log  = 100
          filter_log = 50
        }
      }
      analytics_logs = {
        link_analytics_log_sampling = {
          bid_log = 25
        }
      }
    }
    
    tags = [
      {
        key   = "Environment"
        value = "Production"
      }
    ]
  }
}
```

### Complete Setup with Link
```hcl
module "rtb_fabric" {
  source = "github.com/shapirov103/terraform-aws-rtb-fabric"

  requester_app = {
    create             = true
    app_name           = "my-requester"
    description        = "Requester app"
    vpc_id             = "vpc-xxx"
    subnet_ids         = ["subnet-xxx"]
    security_group_ids = ["sg-xxx"]
    client_token       = "token"
  }

  responder_app = {
    create               = true
    app_name             = "my-responder"
    description          = "Responder app"
    vpc_id               = "vpc-xxx"
    subnet_ids           = ["subnet-xxx"]
    security_group_ids   = ["sg-xxx"]
    port                 = 8080
    protocol             = "HTTPS"
    dns_name             = "app.example.com"
    ca_certificate_chain = "LS0tLS..."
  }

  link = {
    create          = true
    rtb_app_id      = module.rtb_fabric.requester_app_id
    peer_rtb_app_id = module.rtb_fabric.responder_app_id
  }
}
```

## Testing

### End-to-End Testing

Use the provided Makefile for comprehensive testing:

```bash
# Run full end-to-end test (deploy + destroy)
make e2e-test

# Deploy resources only
make deploy

# Destroy resources only
make destroy

# Clean Terraform state files
make clean

# Show available targets
make help
```

**E2E Test includes:**
- 1 Requester RTB App
- 1 EKS Responder RTB App (with auto RBAC)
- 1 ASG Responder RTB App
- 2 RTB Fabric Links

**Environment Variables:**
- `AWS_PROFILE` - AWS profile to use (default: `shapirov+2-Admin`)

## Compatibility

This module is compatible with:
- **Terraform** >= 1.0 (note: versions 1.6+ use BSL license)
- **OpenTofu** >= 1.6 (open-source alternative with MPL-2.0 license)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| awscc | >= 0.70.0 |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| requester_app | Requester RTB app configuration | object | {} |
| responder_app | Responder RTB app configuration | object | {} |
| link | RTB fabric link configuration | object | {} |

## Outputs

| Name | Description |
|------|-------------|
| requester_app_id | ID of the created requester RTB application |
| requester_app_arn | ARN of the created requester RTB application |
| requester_app_endpoint | Endpoint of the created requester RTB application |
| requester_app_status | Status of the created requester RTB application |
| responder_app_id | ID of the created responder RTB application |
| responder_app_arn | ARN of the created responder RTB application |
| responder_app_status | Status of the created responder RTB application |
| link_id | ID of the created RTB fabric link |
| link_arn | ARN of the created RTB fabric link |
| link_state | State of the created RTB fabric link |
| link_direction | Direction of the created RTB fabric link |
| link_public_endpoint | Public endpoint of the created RTB fabric link |