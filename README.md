# Terraform AWS RTB Fabric Module

This module creates AWS RTB Fabric resources using Cloud Control APIs with GA schema support. It supports creating:
- Requester RTB Fabric Gateways
- Responder RTB Fabric Gateways (with managed EKS endpoints and customer role support)
- RTB Fabric Links with advanced configuration options

## Key Features

- **GA Schema Support**: Uses the latest RTB Fabric GA API schema
- **Customer Role Model**: Supports customer-managed IAM roles with RTB Fabric service trust relationships
- **Automatic Configuration**: Can automatically configure customer role trust policies and EKS permissions
- **Manual Setup Support**: Validates pre-configured customer roles for production environments
- **EKS Integration**: Native support for EKS managed endpoints with RBAC automation
- **EKS Discovery Role**: Automatically creates RTBFabricEKSDiscoveryRole with minimal permissions for Kubernetes API access
- **Customizable Role Names**: Supports custom naming for EKS Discovery Role to meet enterprise naming conventions

## EKS Service Discovery Role Requirements

When using EKS managed endpoints, you need an EKS Service Discovery Role that RTB Fabric service can assume. The module supports three configuration approaches:

### Prerequisites

- **EKS Cluster**: Must support **EKS access entries** (API or API_AND_CONFIG_MAP authentication mode)
  - ⚠️ **ConfigMap-only mode is not supported** - the cluster must be configured to use access entries
- **Kubernetes Endpoint**: Target endpoint resource must exist in the specified namespace

### 1. Automatic Setup (Recommended for Development)
Don't specify `eks_service_discovery_role`. Set `auto_create_access = true` and `auto_create_rbac = true`. The module will:
- Check if EKS Service Discovery Role already exists
- Use existing role if found, otherwise create new role with RTB Fabric service trust relationship
- Create EKS access entries for the role
- Create Kubernetes RBAC resources for endpoint access

**Note:** The module automatically handles existing roles. If the role exists but lacks proper permissions, you may need to specify `eks_service_discovery_role` parameter for manual control.

### 2. Hybrid Setup (Recommended for Staging)
Specify existing `eks_service_discovery_role = "MyExistingRole"`. Set `auto_create_access = true` and `auto_create_rbac = true`. The module will:
- Use your existing role (must have RTB Fabric trust relationship)
- Attach the AmazonEKSViewPolicy to your role
- Create EKS access entries for your role
- Create Kubernetes RBAC resources for endpoint access

### 3. Manual Setup (Recommended for Production)
Specify existing `eks_service_discovery_role = "MyExistingRole"`. Set `auto_create_access = false` and `auto_create_rbac = false`. You must pre-configure:

1. **Trust Policy**: EKS Service Discovery Role must trust RTB Fabric service principals:
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

2. **IAM Policy**: Attach `AmazonEKSViewPolicy` to the EKS Service Discovery Role
3. **EKS Access**: Create EKS access entry for the EKS Service Discovery Role
4. **Kubernetes RBAC**: Create Role and RoleBinding for endpoint access

The module will validate all requirements and provide clear error messages if anything is missing.

### EKS Discovery Role Customization
For enterprise environments with specific naming conventions, you can customize the EKS Discovery Role name:

```hcl
module "rtb_fabric" {
  source = "github.com/shapirov103/terraform-aws-rtb-fabric"
  
  # Custom role name following enterprise naming convention
  rtbfabric_eks_discovery_role_name = "MyCompany-RTBFabric-EKS-Discovery-Role"
  
  responder_gateway = {
    # ... other configuration
  }
}
```

The role will be created with minimal permissions (`eks:DescribeCluster`) and can be referenced in your `cluster_access_role_arn` parameter.

### Terraform EKS Cluster Access

When creating Kubernetes RBAC resources, Terraform needs access to the EKS cluster. You can control this access using the `cluster_access_role_arn` parameter:

- **Default behavior**: If `cluster_access_role_arn` is not specified, Terraform uses the current AWS credentials to access the EKS cluster
- **Custom role**: If `cluster_access_role_arn` is specified, Terraform assumes this role to access the EKS cluster

**Important**: The `cluster_access_role_arn` is only used by Terraform during resource creation and is **not used by the RTB Fabric service**. The RTB Fabric service uses the `eks_service_discovery_role` for its operations.

```hcl
# Get current AWS account ID
data "aws_caller_identity" "current" {}

responder_gateway = {
  managed_endpoint_configuration = {
    eks_endpoints_configuration = {
      # Role used by RTB Fabric service (required)
      eks_service_discovery_role = "RTBFabricServiceRole"
      
      # Role used by Terraform for RBAC creation (optional)
      cluster_access_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TerraformEKSAccessRole"
      
      # Other configuration...
    }
  }
}
```

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

### Responder Gateway with EKS Endpoints (Automatic Setup)
```hcl
module "rtb_fabric" {
  source = "github.com/shapirov103/terraform-aws-rtb-fabric"

  responder_gateway = {
    create               = true
    description          = "RTB Fabric responder with EKS endpoints"
    vpc_id               = "vpc-00108ced4ec00636b"
    subnet_ids           = ["subnet-0e656d1ce3ba7d025", "subnet-0efd6f0427bfe0a3b"]
    security_group_ids   = ["sg-050ebc8a5303a9337"]
    port                 = 8080
    protocol             = "HTTPS"
    trust_store_configuration = {
      certificate_authority_certificates = ["LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t..."]
    }

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "nginx-deployment"
        endpoints_resource_namespace = "default"
        cluster_name                 = "my-eks-cluster"
        # eks_service_discovery_role not specified - will create default role automatically
        auto_create_access           = true  # Automatically configure role and EKS access
        auto_create_rbac             = true  # Automatically create Kubernetes RBAC
      }
    }
    
    tags = [
      {
        key   = "Environment"
        value = "Development"
      }
    ]
  }
}
```

### Responder Gateway with EKS Endpoints (Hybrid Setup)
```hcl
module "rtb_fabric" {
  source = "github.com/shapirov103/terraform-aws-rtb-fabric"

  responder_gateway = {
    create               = true
    description          = "Staging RTB Fabric responder"
    vpc_id               = "vpc-00108ced4ec00636b"
    subnet_ids           = ["subnet-0e656d1ce3ba7d025", "subnet-0efd6f0427bfe0a3b"]
    security_group_ids   = ["sg-050ebc8a5303a9337"]
    port                 = 8080
    protocol             = "HTTPS"
    trust_store_configuration = {
      certificate_authority_certificates = ["LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t..."]
    }

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder-service"
        endpoints_resource_namespace = "staging"
        cluster_name                 = "staging-eks-cluster"
        eks_service_discovery_role   = "MyCompany-RTBFabric-EKS-Role"  # Use existing role
        auto_create_access           = true  # But still auto-create EKS access entry
        auto_create_rbac             = true  # And auto-create RBAC
      }
    }
    
    tags = [
      {
        key   = "Environment"
        value = "Staging"
      }
    ]
  }
}
```

### Responder Gateway with EKS Endpoints (Manual Setup)
```hcl
module "rtb_fabric" {
  source = "github.com/shapirov103/terraform-aws-rtb-fabric"

  responder_gateway = {
    create               = true
    description          = "Production RTB Fabric responder"
    vpc_id               = "vpc-00108ced4ec00636b"
    subnet_ids           = ["subnet-0e656d1ce3ba7d025", "subnet-0efd6f0427bfe0a3b"]
    security_group_ids   = ["sg-050ebc8a5303a9337"]
    port                 = 8080
    protocol             = "HTTPS"
    trust_store_configuration = {
      certificate_authority_certificates = ["LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t..."]
    }

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder-service"
        endpoints_resource_namespace = "production"
        cluster_name                 = "prod-eks-cluster"
        eks_service_discovery_role   = "ProdRTBFabricEKSRole"  # Use existing role
        auto_create_access           = false  # Role already configured manually
        auto_create_rbac             = false  # RBAC already configured manually
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
| requester_gateway | Requester RTB Fabric gateway configuration | object | {} |
| responder_gateway | Responder RTB Fabric gateway configuration | object | {} |
| link | RTB Fabric link configuration | object | {} |
| rtbfabric_eks_discovery_role_name | Name for the RTB Fabric EKS Discovery Role (created when eks_service_discovery_role is not provided) | string | "RTBFabricEKSDiscoveryRole" |

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
| eks_service_discovery_role_arn | ARN of the EKS Service Discovery Role (auto-created or provided) |
| eks_service_discovery_role_name | Name of the EKS Service Discovery Role (auto-created or provided) |