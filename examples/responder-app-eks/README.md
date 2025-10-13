# Responder App with EKS Endpoints Example

Creates an RTB Fabric responder application with EKS endpoints using auto-configuration.

## Features

- **Auto-retrieves** cluster endpoint URI and CA certificate from cluster name
- **Auto-creates** EKS access entry for Heimdall role (optional)
- **Auto-creates** RBAC permissions for endpoint access (optional)
- **Flexible authentication** - supports custom cluster access role
- **Minimal configuration** - only requires cluster name and endpoint details

## Prerequisites

- EKS cluster with `API` or `API_AND_CONFIG_MAP` authentication mode (for access entries)
- IAM role with EKS permissions for cluster access (if using `cluster_access_role_arn`)
- Kubernetes endpoint resource deployed in the cluster

## Usage

1. Update `main.tf` with your:
   - AWS resource IDs (VPC, subnets, security groups)
   - EKS cluster name
   - Endpoint resource name and namespace
   - Cluster access role ARN (optional)
2. Run:
```bash
terraform init
terraform plan
terraform apply

# View outputs after deployment
terraform output

# Get specific output
terraform output responder_app_id
```

## Configuration Options

### Auto-Configuration
- `auto_create_access = true` - Creates EKS access entries automatically
- `auto_create_rbac = true` - Creates Kubernetes RBAC resources automatically
- `cluster_access_role_arn` - IAM role for Kubernetes API access (optional)

### Manual Configuration
- Set `auto_create_access = false` to manage EKS access entries manually
- Set `auto_create_rbac = false` to manage RBAC manually
- Provide `cluster_api_server_endpoint_uri` and `cluster_api_server_ca_certificate_chain` to bypass auto-retrieval

## Resources Created

- 1 RTB Fabric Responder App with EKS endpoints
- 1 EKS Access Entry for Heimdall role (if `auto_create_access = true`)
- 1 EKS Access Policy Association with namespace scope (if `auto_create_access = true`)
- 1 Kubernetes Role for endpoint access (if `auto_create_rbac = true`)
- 1 Kubernetes RoleBinding (if `auto_create_rbac = true`)

## Benefits

- **Reduced configuration** - auto-retrieves cluster details
- **Automatic RBAC** - sets up proper permissions for Heimdall role
- **Flexible authentication** - supports different cluster access patterns
- **Validation** - ensures role can access the specified endpoint resource