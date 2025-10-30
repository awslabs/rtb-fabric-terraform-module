# Design Document

## Overview

This design implements a configuration management system for Terraform examples that extracts only essential account-specific values while maintaining backward compatibility and simplicity. The solution focuses on the minimal set of values that cannot be auto-discovered: cluster names and authentication role ARNs.

## Architecture

### Configuration Hierarchy

The design follows a three-tier configuration approach:

1. **Auto-Discovery (Preferred)**: Network resources discovered from EKS cluster tags
2. **Variable Configuration**: Essential account-specific values in terraform.tfvars
3. **Hardcoded Defaults**: Application-level parameters embedded in examples

```
┌─────────────────────────────────────────────────────────────┐
│                    Configuration Sources                     │
├─────────────────────────────────────────────────────────────┤
│ Auto-Discovery:     VPC, Subnets, Security Groups          │
│ Variables:          cluster_name, kubernetes_auth_role_arn  │
│ Hardcoded:          namespace, ports, descriptions         │
└─────────────────────────────────────────────────────────────┘
```

### File Structure Pattern

Each example will follow this standardized structure:

```
examples/{example-name}/
├── main.tf                    # Core Terraform configuration
├── variables.tf               # Variable definitions (minimal set)
├── kubernetes-provider.tf     # Provider configuration (if needed)
├── terraform.tfvars.example   # Template for customers
├── terraform.tfvars          # Current working values (gitignored)
├── .gitignore                # Excludes customer configurations
└── README.md                 # Setup instructions
```

## Components and Interfaces

### Variable Interface

Each example exposes a minimal, standardized variable interface:

```hcl
# Required Variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

# Optional Variables (context-dependent)
variable "kubernetes_auth_role_arn" {
  description = "IAM role ARN for Kubernetes provider authentication"
  type        = string
  default     = null
}

# Network Override Variables (only for examples that support manual configuration)
variable "vpc_id" {
  description = "VPC ID override (uses auto-discovery if null)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs override (uses auto-discovery if null)"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "Security group IDs override (uses auto-discovery if null)"
  type        = list(string)
  default     = null
}
```

### Configuration Templates

#### terraform.tfvars.example Template

```hcl
# RTB Fabric Example Configuration Template
# Copy this file to terraform.tfvars and customize for your environment

# REQUIRED: Your EKS cluster name
cluster_name = "my-cluster-name"

# OPTIONAL: IAM role for Kubernetes authentication
# Leave null to use current AWS credentials
kubernetes_auth_role_arn = null
# kubernetes_auth_role_arn = "arn:aws:iam::123456789012:role/MyEKSAccessRole"

# OPTIONAL: Network configuration overrides
# Leave null to use auto-discovery from EKS cluster tags
vpc_id = null
subnet_ids = null
security_group_ids = null

# Example manual network configuration:
# vpc_id = "vpc-01234567890abcdef"
# subnet_ids = ["subnet-01234567890abcdef", "subnet-fedcba0987654321"]
# security_group_ids = ["sg-01234567890abcdef"]
```

#### terraform.tfvars Working Values

```hcl
# Current working configuration - maintains existing functionality
cluster_name = "rtbkit-shapirov-iad"
kubernetes_auth_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/rtbkit-shapirov-iad-EksAccessRole-CA7FhiO8nskv"
```

### Auto-Discovery Integration

The design leverages existing auto-discovery mechanisms:

```hcl
# Network Configuration Resolution
locals {
  # Use manual override if provided, otherwise auto-discover
  vpc_id = var.vpc_id != null ? var.vpc_id : module.cluster_discovery.discovered_vpc_id
  subnet_ids = var.subnet_ids != null ? var.subnet_ids : module.cluster_discovery.discovered_private_subnet_ids
  security_group_ids = var.security_group_ids != null ? var.security_group_ids : [module.cluster_discovery.discovered_security_group_id]
}
```

### Provider Configuration Pattern

For examples requiring Kubernetes provider configuration:

```hcl
provider "kubernetes" {
  host                   = module.cluster_discovery.discovered_cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster_discovery.discovered_cluster_ca_certificate)
  alias = "responder"
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = var.kubernetes_auth_role_arn != null ? [
      "eks", "get-token", "--cluster-name", var.cluster_name,
      "--role-arn", var.kubernetes_auth_role_arn
    ] : [
      "eks", "get-token", "--cluster-name", var.cluster_name
    ]
  }
}
```

## Data Models

### Configuration Value Classification

Values are classified into three categories:

```yaml
Auto-Discoverable:
  - vpc_id: "Discovered from kubernetes.io/cluster/<cluster_name> tags"
  - subnet_ids: "Discovered from kubernetes.io/role/internal-elb=1 tags"
  - security_group_ids: "Retrieved from EKS cluster configuration"
  - cluster_endpoint: "Retrieved from EKS cluster API"
  - cluster_ca_certificate: "Retrieved from EKS cluster API"

Account-Specific:
  - cluster_name: "Customer's EKS cluster identifier"
  - kubernetes_auth_role_arn: "Customer's IAM role for cluster access"
  - vpc_id: "Manual override for non-standard configurations"
  - subnet_ids: "Manual override for non-standard configurations"
  - security_group_ids: "Manual override for non-standard configurations"

Application-Level:
  - endpoints_resource_name: "Kubernetes service/endpoints name"
  - endpoints_resource_namespace: "Kubernetes namespace"
  - gateway_description: "Human-readable gateway description"
  - port: "Application port number"
  - protocol: "HTTP/HTTPS protocol selection"
```

### Example-Specific Variable Sets

Different examples require different variable subsets:

```yaml
responder-gateway-eks:
  required: [cluster_name]
  optional: [kubernetes_auth_role_arn]
  
responder-gateway-basic:
  required: [vpc_id, subnet_ids, security_group_ids]
  optional: []
  
e2e-test:
  required: [requester_cluster_name, responder_cluster_name]
  optional: [kubernetes_auth_role_arn]
  
requester-gateway:
  required: [cluster_name]
  optional: []
```

## Error Handling

### Validation Strategy

```hcl
# Cluster name validation
validation {
  condition     = length(var.cluster_name) > 0
  error_message = "Cluster name must not be empty."
}

# Role ARN validation (when provided)
validation {
  condition = var.kubernetes_auth_role_arn == null || can(regex("^arn:aws:iam::", var.kubernetes_auth_role_arn))
  error_message = "kubernetes_auth_role_arn must be a valid IAM role ARN starting with 'arn:aws:iam::'."
}
```

### Auto-Discovery Failure Handling

```hcl
# Graceful fallback with clear error messages
locals {
  vpc_discovery_failed = length(module.cluster_discovery.discovered_vpc_id) == 0
  
  error_message = local.vpc_discovery_failed ? 
    "Auto-discovery failed for cluster '${var.cluster_name}'. Please verify the cluster exists and has proper tags, or provide manual network configuration via vpc_id, subnet_ids, and security_group_ids variables." : 
    ""
}

# Conditional error generation
resource "null_resource" "discovery_validation" {
  count = local.vpc_discovery_failed ? 1 : 0
  
  provisioner "local-exec" {
    command = "echo 'ERROR: ${local.error_message}' && exit 1"
  }
}
```

## Testing Strategy

### Validation Scenarios

1. **Auto-Discovery Success**: Verify examples work with only cluster_name provided
2. **Manual Override**: Verify examples work with manual network configuration
3. **Authentication Variants**: Test both current credentials and role-based authentication
4. **Backward Compatibility**: Ensure existing terraform.tfvars files continue to work
5. **Error Handling**: Verify clear error messages for invalid configurations

### Test Configuration Matrix

```yaml
Test Scenarios:
  - name: "minimal-config"
    variables: {cluster_name: "test-cluster"}
    expected: "auto-discovery used"
    
  - name: "manual-network"
    variables: {cluster_name: "test-cluster", vpc_id: "vpc-123", subnet_ids: ["subnet-123"]}
    expected: "manual configuration used"
    
  - name: "role-auth"
    variables: {cluster_name: "test-cluster", kubernetes_auth_role_arn: "arn:aws:iam::123:role/test"}
    expected: "role-based authentication used"
    
  - name: "invalid-cluster"
    variables: {cluster_name: "nonexistent-cluster"}
    expected: "clear error message about discovery failure"
```

### Output Verification

Each example provides transparency outputs:

```hcl
# Configuration source tracking
output "configuration_summary" {
  description = "Summary of configuration sources used"
  value = {
    cluster_name_source = "variable"
    vpc_source = var.vpc_id != null ? "manual" : "auto-discovery"
    subnet_source = var.subnet_ids != null ? "manual" : "auto-discovery"
    security_group_source = var.security_group_ids != null ? "manual" : "auto-discovery"
    authentication_source = var.kubernetes_auth_role_arn != null ? "role-based" : "current-credentials"
  }
}

# Discovered values for transparency
output "discovered_values" {
  description = "Values discovered automatically"
  value = {
    vpc_id = module.cluster_discovery.discovered_vpc_id
    subnet_ids = module.cluster_discovery.discovered_private_subnet_ids
    security_group_id = module.cluster_discovery.discovered_security_group_id
  }
}

# Final values used
output "used_values" {
  description = "Final configuration values used in deployment"
  value = {
    vpc_id = local.vpc_id
    subnet_ids = local.subnet_ids
    security_group_ids = local.security_group_ids
  }
}
```

## Implementation Phases

### Phase 1: Core Examples (Priority)
- `examples/responder-gateway-eks`
- `examples/requester-gateway`
- `examples/e2e-test`

### Phase 2: Specialized Examples
- `examples/responder-gateway-basic`
- `examples/responder-gateway-asg`
- `examples/responder-gateway-eks-hybrid`

### Phase 3: Documentation and Validation
- Update README files with setup instructions
- Add validation tests for configuration scenarios
- Create migration guide for existing users

## Backward Compatibility

### Migration Strategy

1. **Preserve Existing Functionality**: Include terraform.tfvars with current hardcoded values
2. **Gradual Adoption**: Customers can migrate to terraform.tfvars.example at their own pace
3. **Clear Documentation**: Provide migration instructions in README files
4. **Version Control Safety**: .gitignore prevents accidental commits of customer configurations

### Compatibility Matrix

```yaml
Existing Deployments:
  status: "Fully Compatible"
  reason: "terraform.tfvars maintains exact current values"
  
New Deployments:
  status: "Enhanced Experience"
  reason: "terraform.tfvars.example provides clear customization path"
  
CI/CD Pipelines:
  status: "No Changes Required"
  reason: "Existing terraform.tfvars files continue to work"
```