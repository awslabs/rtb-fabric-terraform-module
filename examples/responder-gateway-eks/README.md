# RTB Fabric Responder Gateway with EKS Endpoints (Automatic Setup)

Creates an RTB Fabric responder gateway with EKS endpoints using automatic role configuration.

## Features

- **Auto-retrieves** cluster endpoint URI and CA certificate from cluster name
- **Auto-configures** customer role trust policy with RTB Fabric service principals
- **Auto-creates** EKS access entry for customer role (optional)
- **Auto-creates** RBAC permissions for endpoint access (optional)
- **Flexible authentication** - supports custom cluster access role
- **Customer role required** - uses customer-managed IAM role instead of legacy HeimdallAssumeRole

## Prerequisites

- EKS cluster with `API` or `API_AND_CONFIG_MAP` authentication mode (for access entries)
- Customer-managed IAM role for RTB Fabric service access
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

### Auto-Configuration (Default)
- `customer_role_arn` - **Required** customer-managed IAM role ARN
- `auto_create_access = true` - Configures customer role trust policy and creates EKS access entries
- `auto_create_rbac = true` - Creates Kubernetes RBAC resources automatically
- `cluster_access_role_arn` - IAM role for Kubernetes API access (optional)

### Manual Configuration
- Set `auto_create_access = false` to manage role trust policy and EKS access entries manually
- Set `auto_create_rbac = false` to manage RBAC manually
- Provide `cluster_api_server_endpoint_uri` and `cluster_api_server_ca_certificate_chain` to bypass auto-retrieval

## Resources Created

- 1 RTB Fabric Responder Gateway with EKS endpoints
- 1 Customer role trust policy update (if `auto_create_access = true` and trust policy missing)
- 1 IAM policy attachment for AmazonEKSViewPolicy (if `auto_create_access = true`)
- 1 EKS Access Entry for customer role (if `auto_create_access = true`)
- 1 EKS Access Policy Association with namespace scope (if `auto_create_access = true`)
- 1 Kubernetes Role for endpoint access (if `auto_create_rbac = true`)
- 1 Kubernetes RoleBinding (if `auto_create_rbac = true`)

## Benefits

- **Customer role model** - uses customer-managed roles instead of legacy HeimdallAssumeRole
- **Automatic configuration** - sets up trust policies and permissions automatically
- **Validation** - ensures customer role has proper RTB Fabric service trust relationships
- **Flexible setup** - supports both automatic and manual configuration approaches