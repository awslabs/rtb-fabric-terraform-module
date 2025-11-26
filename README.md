# Terraform AWS RTB Fabric Module

[![Version](https://img.shields.io/github/v/release/awslabs/rtb-fabric-terraform-module)](https://github.com/awslabs/rtb-fabric-terraform-module/releases)
[![License](https://img.shields.io/github/license/awslabs/rtb-fabric-terraform-module)](LICENSE)

This module creates AWS RTB Fabric resources using Cloud Control APIs with GA schema support. It supports creating:
- Requester RTB Fabric Gateways
- Responder RTB Fabric Gateways (with managed EKS endpoints and customer role support)
- RTB Fabric Links with advanced configuration options
- Inbound External Links for accepting connections from external RTB Fabric gateways

## Key Features

- **GA Schema Support**: Uses the latest RTB Fabric GA API schema
- **Automatic Configuration**: Can automatically configure customer role trust policies and EKS permissions
- **Manual Setup Support**: Validates pre-configured customer roles for production environments
- **EKS Integration**: Native support for EKS managed endpoints with RBAC automation
- **EKS Discovery Role**: Automatically creates RTBFabricEKSDiscoveryRole with minimal permissions for Kubernetes API access
- **Customizable Role Names**: Supports custom naming for EKS Discovery Role to meet enterprise naming conventions

## Role Management for Managed Endpoints

When using managed endpoints (EKS or ASG), RTB Fabric service requires IAM roles to discover and access your infrastructure. The module provides flexible role management with the `auto_create_role` parameter, suitable for both development and production environments.

## Installation

### Using Pinned Version (Recommended)
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module?ref=v0.3.0"
  
  # Your configuration here
  requester_gateway = {
    create = true
    # ... configuration
  }
}
```

### Using Latest Version
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"
  
  # Your configuration here
}
```

### Prerequisites

For **EKS managed endpoints**:
- **EKS Cluster**: Must support **EKS access entries** (API or API_AND_CONFIG_MAP authentication mode)
  - ⚠️ **ConfigMap-only mode is not supported** - the cluster must be configured to use access entries
- **Kubernetes Endpoint**: Target endpoint resource must exist in the specified namespace

For **ASG managed endpoints**:
- **Auto Scaling Groups**: Must exist and be accessible in the target AWS account
- **EC2 Instances**: Must be running and accessible for endpoint discovery

### Role Auto-Creation (`auto_create_role`)

The `auto_create_role` parameter controls whether the module creates IAM roles or assumes they already exist. This feature is **production-ready** and allows customers to specify custom role names while maintaining security best practices.

#### 1. Automatic Role Creation (Default - Production Ready)
Set `auto_create_role = true` (default) and optionally specify a custom role name. The module will:
- Create the specified role with proper RTB Fabric service trust relationships
- Attach required permissions (EKS: `eks:DescribeCluster`, ASG: ASG discovery permissions)
- Handle role naming conflicts gracefully with clear error messages

```hcl
managed_endpoint_configuration = {
  eks_endpoints_configuration = {
    # Custom role name for your environment
    eks_service_discovery_role = "MyCompany-RTBFabric-EKS-Role"
    auto_create_role          = true  # Creates the role (default)
    # ... other configuration
  }
}
```

#### 2. Use Existing Roles (Compliance/Hybrid Setup)
Set `auto_create_role = false` when roles must be created through your organization's compliance processes. The module will:
- Assume the specified role already exists
- Validate the role has proper trust relationships and permissions
- Provide clear error messages if configuration is missing

```hcl
managed_endpoint_configuration = {
  eks_endpoints_configuration = {
    eks_service_discovery_role = "PreCreated-RTBFabric-Role"
    auto_create_role          = false  # Use existing role
    # ... other configuration
  }
}
```

#### 3. Default Role Names (Simplified Setup)
Don't specify a role name. The module will use default names and create them automatically:
- EKS: `RTBFabricEKSDiscoveryRole` (customizable via `rtbfabric_eks_discovery_role_name`)
- ASG: `RTBFabricAsgDiscoveryRole` (customizable via `rtbfabric_asg_discovery_role_name`)

### EKS Configuration Approaches

#### Automatic Setup with Custom Role (Recommended)
```hcl
managed_endpoint_configuration = {
  eks_endpoints_configuration = {
    endpoints_resource_name      = "bidder-service"
    endpoints_resource_namespace = "production"
    cluster_name                 = "prod-eks-cluster"
    # Custom role name with auto-creation
    eks_service_discovery_role   = "MyCompany-RTBFabric-EKS-Role"
    auto_create_role            = true   # Create the role
    auto_create_access          = true   # Create EKS access entries
    auto_create_rbac            = true   # Create Kubernetes RBAC
  }
}
```

#### Hybrid Setup (Custom Role, Auto EKS/RBAC)
```hcl
managed_endpoint_configuration = {
  eks_endpoints_configuration = {
    # Use existing role, but auto-configure EKS access and RBAC
    eks_service_discovery_role = "PreExisting-RTBFabric-Role"
    auto_create_role          = false  # Role exists
    auto_create_access        = true   # Auto-create EKS access
    auto_create_rbac          = true   # Auto-create RBAC
    # ... other configuration
  }
}
```

#### Manual Setup (Full Control)
```hcl
managed_endpoint_configuration = {
  eks_endpoints_configuration = {
    eks_service_discovery_role = "FullyManaged-RTBFabric-Role"
    auto_create_role          = false  # Role exists
    auto_create_access        = false  # EKS access pre-configured
    auto_create_rbac          = false  # RBAC pre-configured
    # ... other configuration
  }
}
```

### ASG Configuration Approaches

#### Automatic Setup with Custom Role (Recommended)
```hcl
managed_endpoint_configuration = {
  auto_scaling_groups_configuration = {
    auto_scaling_group_name_list = ["my-asg-1", "my-asg-2"]
    # Custom role name with auto-creation
    asg_discovery_role = "MyCompany-RTBFabric-ASG-Role"
    auto_create_role   = true  # Create the role (default)
  }
}
```

#### Use Existing Role (Compliance Setup)
```hcl
managed_endpoint_configuration = {
  auto_scaling_groups_configuration = {
    auto_scaling_group_name_list = ["my-asg-1", "my-asg-2"]
    asg_discovery_role = "PreExisting-RTBFabric-ASG-Role"
    auto_create_role   = false  # Use existing role
  }
}
```

### Required Trust Policy for Manual Setup

When using `auto_create_role = false`, ensure your existing roles have the correct trust policy:

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

### Benefits of Auto-Create Role

The `auto_create_role` functionality provides several advantages:

**🚀 Production Ready**: Suitable for all environments, from development to production
**🔒 Security**: Creates roles with minimal required permissions and proper trust policies
**🏢 Enterprise Friendly**: Supports custom role names to meet organizational naming conventions
**🔄 Conflict Resolution**: Handles role naming conflicts gracefully with clear error messages
**🛠️ Flexibility**: Allows hybrid setups where roles are pre-created but EKS/RBAC is auto-configured
**📋 Compliance**: Supports compliance requirements by allowing existing roles with `auto_create_role = false`

### Role Naming Customization

For enterprise environments with specific naming conventions, you can customize default role names:

```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"
  
  # Custom default role names following enterprise naming convention
  rtbfabric_eks_discovery_role_name = "MyCompany-RTBFabric-EKS-Discovery-Role"
  rtbfabric_asg_discovery_role_name = "MyCompany-RTBFabric-ASG-Discovery-Role"
  
  responder_gateway = {
    # ... other configuration
  }
}
```

These names are used when role names are not explicitly specified in the managed endpoint configuration.

### Kubernetes Provider Configuration

When using EKS managed endpoints, the module requires a kubernetes provider to create RBAC resources. The module supports flexible provider configuration patterns:

#### Single Cluster (Default Provider)
```hcl
# Configure kubernetes provider for your EKS cluster
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "my-cluster"]
  }
}

module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"
  # Uses the default kubernetes provider above
  responder_gateway = {
    # ... EKS configuration
  }
}
```

#### Multi-Cluster (Explicit Provider Passing)
```hcl
# Multiple kubernetes providers for different clusters
provider "kubernetes" {
  alias = "cluster_a"
  host  = data.aws_eks_cluster.cluster_a.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_a.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "cluster-a"]
  }
}

provider "kubernetes" {
  alias = "cluster_b"
  host  = data.aws_eks_cluster.cluster_b.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_b.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "cluster-b"]
  }
}

# Multiple responder gateways on different clusters
module "rtb_fabric_cluster_a" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"
  
  providers = {
    kubernetes = kubernetes.cluster_a
  }
  
  responder_gateway = {
    # ... cluster A configuration
  }
}

module "rtb_fabric_cluster_b" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"
  
  providers = {
    kubernetes = kubernetes.cluster_b
  }
  
  responder_gateway = {
    # ... cluster B configuration
  }
}
```

#### Authentication with IAM Roles
```hcl
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token", "--cluster-name", "my-cluster",
      "--role-arn", "arn:aws:iam::123456789012:role/MyEKSAccessRole"
    ]
  }
}
```

**Important Notes:**
- **ASG examples don't need kubernetes provider** - the module handles this automatically
- **EKS examples require kubernetes provider** - configure it to match your cluster
- **Multi-cluster scenarios** - use explicit provider passing with aliases
- **Authentication flexibility** - supports various AWS authentication methods

## Usage Examples

### Requester Gateway Only
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  requester_gateway = {
    create             = true
    description        = "Production requester gateway"
    vpc_id             = "vpc-00108ced4ec00636b"
    subnet_ids         = ["subnet-0e656d1ce3ba7d025", "subnet-0efd6f0427bfe0a3b"]
    security_group_ids = ["sg-050ebc8a5303a9337"]
    tags = {
      Environment = "Production"
      Team        = "Platform"
    }
  }
}
```

### Basic Responder Gateway
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  responder_gateway = {
    create             = true
    description        = "Basic responder gateway"
    vpc_id             = "vpc-00108ced4ec00636b"
    subnet_ids         = ["subnet-0e656d1ce3ba7d025"]
    security_group_ids = ["sg-050ebc8a5303a9337"]
    port               = 8080
    protocol           = "HTTP"
    domain_name        = "my-app.example.com"
    tags = {
      Environment = "Development"
    }
  }
}
```

### Responder Gateway with EKS Endpoints (Auto-Create Custom Role)
```hcl
# Get current AWS account ID for role ARN construction
data "aws_caller_identity" "current" {}

# EKS cluster data for kubernetes provider configuration
data "aws_eks_cluster" "cluster" {
  name = "my-eks-cluster"
}

# Kubernetes provider configuration for EKS cluster
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "my-eks-cluster"]
  }
}

module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  responder_gateway = {
    create             = true
    description        = "EKS responder with custom auto-created role"
    vpc_id             = "vpc-00108ced4ec00636b"
    subnet_ids         = ["subnet-0e656d1ce3ba7d025", "subnet-0efd6f0427bfe0a3b"]
    security_group_ids = ["sg-050ebc8a5303a9337"]
    port               = 8090
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder-internal"
        endpoints_resource_namespace = "default"
        cluster_name                 = "my-eks-cluster"
        # Custom role name with auto-creation (production ready)
        eks_service_discovery_role   = "MyCompany-RTBFabric-EKS-Role"
        auto_create_role            = true   # Create the role (default)
        auto_create_access          = true   # Auto-configure EKS access
        auto_create_rbac            = true   # Auto-create Kubernetes RBAC
      }
    }
    
    tags = {
      Environment = "Production"
    }
  }
}
```

### Responder Gateway with EKS Endpoints (Use Existing Role)
```hcl
data "aws_caller_identity" "current" {}

# EKS cluster data for kubernetes provider configuration
data "aws_eks_cluster" "cluster" {
  name = "prod-eks-cluster"
}

# Kubernetes provider with IAM role authentication
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token", "--cluster-name", "prod-eks-cluster",
      "--role-arn", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TerraformEKSRole"
    ]
  }
}

module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  responder_gateway = {
    create             = true
    description        = "EKS responder with existing role"
    vpc_id             = "vpc-00108ced4ec00636b"
    subnet_ids         = ["subnet-0e656d1ce3ba7d025", "subnet-0efd6f0427bfe0a3b"]
    security_group_ids = ["sg-050ebc8a5303a9337"]
    port               = 8090
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder-service"
        endpoints_resource_namespace = "production"
        cluster_name                 = "prod-eks-cluster"
        # Use existing role (compliance/hybrid setup)
        eks_service_discovery_role   = "PreExisting-RTBFabric-Role"
        auto_create_role            = false  # Role already exists
        auto_create_access          = true   # Still auto-create EKS access entry
        auto_create_rbac            = true   # Still auto-create RBAC
      }
    }
    
    tags = {
      Environment = "Production"
    }
  }
}
```

### Responder Gateway with EKS Endpoints (Default Role)
```hcl
data "aws_caller_identity" "current" {}

# EKS cluster data for kubernetes provider configuration
data "aws_eks_cluster" "cluster" {
  name = "my-eks-cluster"
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "my-eks-cluster"]
  }
}

module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  # Optional: Customize the default EKS Discovery Role name
  rtbfabric_eks_discovery_role_name = "MyCompany-RTBFabric-EKS-Discovery-Role"

  responder_gateway = {
    create             = true
    description        = "EKS responder with default role"
    vpc_id             = "vpc-00108ced4ec00636b"
    subnet_ids         = ["subnet-0e656d1ce3ba7d025", "subnet-0efd6f0427bfe0a3b"]
    security_group_ids = ["sg-050ebc8a5303a9337"]
    port               = 8090
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder-internal"
        endpoints_resource_namespace = "default"
        cluster_name                 = "my-eks-cluster"
        # eks_service_discovery_role not specified - uses default name
        # auto_create_role = true (default) - creates the role
        auto_create_access          = true   # Auto-configure EKS access
        auto_create_rbac            = true   # Auto-create Kubernetes RBAC
      }
    }
    
    tags = {
      Environment = "Development"
    }
  }
}
```

### Responder Gateway with Auto Scaling Groups (Custom Role)
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  responder_gateway = {
    create             = true
    description        = "ASG responder with custom role"
    vpc_id             = "vpc-00108ced4ec00636b"
    subnet_ids         = ["subnet-0e656d1ce3ba7d025"]
    security_group_ids = ["sg-050ebc8a5303a9337"]
    port               = 8080
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      auto_scaling_groups_configuration = {
        auto_scaling_group_name_list = ["my-asg-1", "my-asg-2"]
        # Custom role name with auto-creation (production ready)
        asg_discovery_role = "MyCompany-RTBFabric-ASG-Role"
        auto_create_role   = true  # Create the role (default)
      }
    }

    tags = {
      Environment = "Production"
    }
  }
}
```

### Responder Gateway with Auto Scaling Groups (Existing Role)
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  responder_gateway = {
    create             = true
    description        = "ASG responder with existing role"
    vpc_id             = "vpc-00108ced4ec00636b"
    subnet_ids         = ["subnet-0e656d1ce3ba7d025"]
    security_group_ids = ["sg-050ebc8a5303a9337"]
    port               = 8080
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      auto_scaling_groups_configuration = {
        auto_scaling_group_name_list = ["my-asg-1", "my-asg-2"]
        # Use existing role (compliance setup)
        asg_discovery_role = "PreExisting-RTBFabric-ASG-Role"
        auto_create_role   = false  # Role already exists
      }
    }

    tags = {
      Environment = "Production"
    }
  }
}
```

### Responder Gateway with Auto Scaling Groups (Default Role)
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  # Optional: Customize the default ASG Discovery Role name
  rtbfabric_asg_discovery_role_name = "MyCompany-RTBFabric-ASG-Discovery-Role"

  responder_gateway = {
    create             = true
    description        = "ASG responder with default role"
    vpc_id             = "vpc-00108ced4ec00636b"
    subnet_ids         = ["subnet-0e656d1ce3ba7d025"]
    security_group_ids = ["sg-050ebc8a5303a9337"]
    port               = 8080
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      auto_scaling_groups_configuration = {
        auto_scaling_group_name_list = ["my-asg-1", "my-asg-2"]
        # asg_discovery_role not specified - uses default name
        # auto_create_role = true (default) - creates the role
      }
    }

    tags = {
      Environment = "Development"
    }
  }
}
```

### Multi-Cluster EKS Deployment
```hcl
# Data sources for multiple clusters
data "aws_eks_cluster" "production" {
  name = "prod-eks-cluster"
}

data "aws_eks_cluster" "staging" {
  name = "staging-eks-cluster"
}

# Kubernetes providers for different clusters
provider "kubernetes" {
  alias = "production"
  host  = data.aws_eks_cluster.production.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.production.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "prod-eks-cluster"]
  }
}

provider "kubernetes" {
  alias = "staging"
  host  = data.aws_eks_cluster.staging.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.staging.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "staging-eks-cluster"]
  }
}

# Production responder gateway
module "rtb_fabric_production" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  providers = {
    kubernetes = kubernetes.production
  }

  responder_gateway = {
    create             = true
    description        = "Production EKS responder gateway"
    vpc_id             = "vpc-prod123"
    subnet_ids         = ["subnet-prod1", "subnet-prod2"]
    security_group_ids = ["sg-prod123"]
    port               = 8080
    protocol           = "HTTPS"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder-service"
        endpoints_resource_namespace = "production"
        cluster_name                 = "prod-eks-cluster"
        eks_service_discovery_role   = "Production-RTBFabric-EKS-Role"
        auto_create_role            = true
        auto_create_access          = true
        auto_create_rbac            = true
      }
    }

    tags = {
      Environment = "Production"
      Cluster     = "prod-eks-cluster"
    }
  }
}

# Staging responder gateway
module "rtb_fabric_staging" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  providers = {
    kubernetes = kubernetes.staging
  }

  responder_gateway = {
    create             = true
    description        = "Staging EKS responder gateway"
    vpc_id             = "vpc-staging123"
    subnet_ids         = ["subnet-staging1", "subnet-staging2"]
    security_group_ids = ["sg-staging123"]
    port               = 8080
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder-service"
        endpoints_resource_namespace = "staging"
        cluster_name                 = "staging-eks-cluster"
        eks_service_discovery_role   = "Staging-RTBFabric-EKS-Role"
        auto_create_role            = true
        auto_create_access          = true
        auto_create_rbac            = true
      }
    }

    tags = {
      Environment = "Staging"
      Cluster     = "staging-eks-cluster"
    }
  }
}
```

### RTB Fabric Link
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  link = {
    create                 = true
    gateway_id             = "rtb-gw-abc123"
    peer_gateway_id        = "rtb-gw-def456"
    http_responder_allowed = true
    
    link_attributes = {
      customer_provided_id = "my-custom-link"
      responder_error_masking = [
        {
          http_code                   = "400"
          action                      = "NO_BID"
          logging_types               = ["METRIC", "RESPONSE"]
          response_logging_percentage = 15.0
        }
      ]
    }
    
    # GA schema requires application_logs structure
    link_log_settings = {
      application_logs = {
        link_application_log_sampling = {
          error_log  = 25
          filter_log = 15
        }
      }
    }

    # GA schema ModuleConfigurationList
    module_configuration_list = [
      {
        name    = "TestNoBidModule"
        version = "v1"
        module_parameters = {
          no_bid = {
            reason                  = "TestReason"
            reason_code             = 2
            pass_through_percentage = 5.0
          }
        }
      }
    ]
    
    tags = {
      Environment = "Production"
      LinkType    = "rtb-link"
    }
  }
}
```

### Inbound External Link
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  inbound_external_link = {
    create     = true
    gateway_id = "rtb-gw-abc123"  # Your responder gateway ID

    link_log_settings = {
      error_log  = 10
      filter_log = 5
    }

    link_attributes = {
      customer_provided_id = "external-partner-link"
      
      responder_error_masking = [
        {
          http_code                   = "400"
          action                      = "NO_BID"
          logging_types               = ["METRIC", "RESPONSE"]
          response_logging_percentage = 15.0
        }
      ]
    }

    tags = {
      Environment = "Production"
      LinkType    = "External"
      Partner     = "CompanyName"
    }
  }
}
```

### Complete Setup with Link
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  requester_gateway = {
    create             = true
    description        = "Complete setup requester"
    vpc_id             = "vpc-xxx"
    subnet_ids         = ["subnet-xxx"]
    security_group_ids = ["sg-xxx"]
    tags = {
      Environment = "Production"
    }
  }

  responder_gateway = {
    create             = true
    description        = "Complete setup responder"
    vpc_id             = "vpc-xxx"
    subnet_ids         = ["subnet-xxx"]
    security_group_ids = ["sg-xxx"]
    port               = 8080
    protocol           = "HTTP"
    domain_name        = "app.example.com"
    tags = {
      Environment = "Production"
    }
  }
}

# Separate module instance for the link
module "rtb_fabric_link" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"

  link = {
    create          = true
    gateway_id      = module.rtb_fabric.requester_gateway_id
    peer_gateway_id = module.rtb_fabric.responder_gateway_id
    
    link_log_settings = {
      application_logs = {
        link_application_log_sampling = {
          error_log  = 10
          filter_log = 5
        }
      }
    }

    tags = {
      Environment = "Production"
    }
  }
}
```

## Development & Testing

### Code Quality & Security Scanning

This module includes comprehensive security and quality scanning tools to ensure best practices and catch issues early.

#### Quick Start

```bash
# Install all scanning tools
make install-tools

# Run all security scans
make security

# Run individual scans
make tflint    # Terraform linting and best practices
make tfsec     # Security vulnerability scanning  
make checkov   # Compliance and policy checking
```

#### Available Tools

- **TFLint**: Terraform linter with AWS-specific rules for catching errors and enforcing best practices
- **TFSec**: Security scanner that detects potential vulnerabilities in Terraform code
- **Checkov**: Static analysis tool for infrastructure compliance and security policies

#### GitHub Actions Integration

Security scans run automatically on:
- **Pull Requests** to main/master branch
- **Manual workflow dispatch** with configurable scan levels:
  - `full` - All checks (default)
  - `security-only` - TFSec + Checkov only
  - `lint-only` - Formatting + TFLint only

Results are posted as PR comments and uploaded as workflow artifacts.

#### Configuration Files

- `.tflint.hcl` - TFLint configuration with AWS plugin
- `.tfsec.yml` - TFSec security scan settings
- `.checkov.yml` - Checkov compliance rules and exclusions

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

# Show all available targets
make help
```

**E2E Test includes:**
- 1 Requester RTB App
- 1 EKS Responder RTB App (with auto RBAC)
- 1 ASG Responder RTB App
- 2 RTB Fabric Links

**Environment Variables:**
- `AWS_PROFILE` - AWS profile to use (default: `shapirov+2-Admin`)

## Troubleshooting

### Known Limitations

#### Link `http_responder_allowed` Field

**Issue**: The `http_responder_allowed` field is not returned by Cloud Control API after link creation, causing state drift.

**Behavior**: 
- This field is immutable (can only be set during creation)
- Cloud Control API does not return it in GetResource responses
- Terraform sees it as `null` in state even when set during creation

**Solution**: 
The module uses `ignore_changes` to handle this automatically. You can set this field during link creation:

```hcl
link = {
  create                 = true
  gateway_id             = "rtb-gw-..."
  peer_gateway_id        = "rtb-gw-..."
  http_responder_allowed = true  # Set on create, ignored on updates
  # ... rest of config
}
```

**How it works**:
1. On **first apply**: The field is sent to AWS with your specified value
2. On **second apply**: An `import` block in your root module refreshes the state from AWS, removing the problematic field
3. On **subsequent applies**: Updates work without errors since the field is no longer in state
4. You can update other fields (`tags`, `link_log_settings`, `module_configuration_list`) without issues

**Requirements**:
- Terraform 1.5+ (for `import` block support)
- Add an `import` block in your root module (see example below)

**How it works**:
1. On **first apply**: The field is sent to AWS with your specified value
2. **Manual cleanup required**: After creation, you must clean up the state once (see below)
3. On **subsequent applies**: Updates work without errors

**Required one-time setup after link creation**:

Option 1 - Use the provided script (recommended):
```bash
# Run from your Terraform root module directory
bash scripts/cleanup-link-state.sh
```

Option 2 - Manual commands:
```bash
# Get the link ARN
LINK_ARN=$(terraform output -raw link_arn)

# Remove and reimport to clean state
terraform state rm 'module.rtb_fabric.awscc_rtbfabric_link.link[0]'
terraform import 'module.rtb_fabric.awscc_rtbfabric_link.link[0]' "$LINK_ARN"

# Verify
terraform plan  # Should show no changes
```

**Why this is needed**:
Cloud Control API doesn't return `http_responder_allowed` in responses, causing the awscc provider to attempt updates on every apply, which fail because the field is immutable. Reimporting refreshes the state without this field.

**Important**: 
- Once set, this field cannot be changed without recreating the link
- If you need to change it, you must destroy and recreate the link resource

#### Link Module Configuration - Responder Side Limitation

**Current Limitation**: Link module configuration and management is currently only supported from the requester side. Module configuration cannot be managed from the responder gateway side at this time.

**Status**: AWS is actively working on enabling responder-side module management support. This functionality will be available in a future release.

### Common Auto-Create Role Issues

#### Role Already Exists Error
```
Error: creating IAM Role (MyCustomRole): EntityAlreadyExists: Role with name MyCustomRole already exists
```
**Solution**: Set `auto_create_role = false` to use the existing role, or choose a different role name.

#### Role Not Found Error
```
Error: reading IAM Role (MyCustomRole): couldn't find resource
```
**Solution**: Either set `auto_create_role = true` to create the role, or ensure the role exists in your AWS account.

#### Trust Policy Validation Failed
```
ERROR: EKS Service Discovery Role trust policy validation failed
```
**Solution**: When using `auto_create_role = false`, ensure your existing role trusts the RTB Fabric service principals:
- `rtbfabric.amazonaws.com`
- `rtbfabric-endpoints.amazonaws.com`

#### Permission Denied on Role Creation
```
Error: creating IAM Role: AccessDenied: User is not authorized to perform: iam:CreateRole
```
**Solution**: Ensure your AWS credentials have IAM permissions to create roles, or use `auto_create_role = false` with pre-created roles.

### Best Practices

1. **Use Custom Role Names**: Specify meaningful role names that follow your organization's naming conventions
2. **Environment-Specific Names**: Include environment identifiers in role names to avoid conflicts
3. **Hybrid Approach**: Use `auto_create_role = false` for roles but `auto_create_access = true` for EKS/RBAC automation
4. **Testing**: Use unique role names in development/testing environments to avoid conflicts

## Contributing

### Before Submitting PRs

1. **Run security scans locally**:
   ```bash
   make security
   ```

2. **Format code**:
   ```bash
   make format
   ```

3. **Run full quality checks**:
   ```bash
   make lint
   ```

### Security Policy

See [SECURITY.md](SECURITY.md) for detailed security guidelines and reporting procedures.

## Compatibility

This module is compatible with:
- **Terraform** >= 1.0 (note: versions 1.6+ use BSL license)
- **OpenTofu** >= 1.6 (open-source alternative with MPL-2.0 license)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |
| kubernetes | >= 2.20 |
| null | >= 3.0 |

### Development Tools (Optional)

For local development and security scanning:

| Tool | Installation | Purpose |
|------|-------------|---------|
| TFLint | `brew install tflint` or `make install-tools` | Terraform linting |
| TFSec | `brew install tfsec` or `make install-tools` | Security scanning |
| Checkov | `pip install checkov` or `make install-tools` | Compliance checking |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| requester_gateway | Requester RTB Fabric gateway configuration | object | {} |
| responder_gateway | Responder RTB Fabric gateway configuration with auto_create_role support | object | {} |
| link | RTB Fabric link configuration | object | {} |
| rtbfabric_eks_discovery_role_name | Name for the RTB Fabric EKS Discovery Role (used when eks_service_discovery_role is not provided) | string | "RTBFabricEKSDiscoveryRole" |
| rtbfabric_asg_discovery_role_name | Name for the RTB Fabric ASG Discovery Role (used when asg_discovery_role is not provided) | string | "RTBFabricAsgDiscoveryRole" |

### Key Configuration Parameters

#### EKS Managed Endpoints
| Parameter | Description | Type | Default |
|-----------|-------------|------|---------|
| eks_service_discovery_role | Custom role name for RTB Fabric service to assume | string | null (uses default name) |
| auto_create_role | Whether to create the eks_service_discovery_role or assume it exists | bool | true |
| auto_create_access | Whether to create EKS access entries automatically | bool | true |
| auto_create_rbac | Whether to create Kubernetes RBAC resources automatically | bool | true |

**Note**: The `cluster_access_role_arn` parameter has been removed. Kubernetes provider authentication is now configured externally for better flexibility and multi-cluster support.

#### ASG Managed Endpoints
| Parameter | Description | Type | Default |
|-----------|-------------|------|---------|
| asg_discovery_role | Custom role name for RTB Fabric service to assume | string | null (uses default name) |
| auto_create_role | Whether to create the asg_discovery_role or assume it exists | bool | true |

## Outputs

| Name | Description |
|------|-------------|
| requester_gateway_id | ID of the created requester RTB gateway |
| requester_gateway_arn | ARN of the created requester RTB gateway |
| requester_gateway_domain_name | Domain name of the created requester RTB gateway |
| requester_gateway_status | Status of the created requester RTB gateway |
| responder_gateway_id | ID of the created responder RTB gateway |
| responder_gateway_arn | ARN of the created responder RTB gateway |
| responder_gateway_domain_name | Domain name of the created responder RTB gateway |
| responder_gateway_status | Status of the created responder RTB gateway |
| link_id | ID of the created RTB fabric link |
| link_arn | ARN of the created RTB fabric link |
| link_status | Status of the created RTB fabric link |
| link_direction | Direction of the created RTB fabric link |
| eks_service_discovery_role_arn | ARN of the EKS Service Discovery Role (auto-created or provided) |
| eks_service_discovery_role_name | Name of the EKS Service Discovery Role (auto-created or provided) |
| asg_service_discovery_role_arn | ARN of the ASG Service Discovery Role (auto-created or provided) |
| asg_service_discovery_role_name | Name of the ASG Service Discovery Role (auto-created or provided) |