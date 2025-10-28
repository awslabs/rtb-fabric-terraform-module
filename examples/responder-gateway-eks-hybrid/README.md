# RTB Fabric Responder Gateway with EKS Endpoints (Hybrid Setup)

This example demonstrates the **hybrid approach** where you create an EKS Service Discovery Role and let the module automatically create EKS access entries and Kubernetes RBAC.

## What This Example Creates

This complete, runnable example creates:

1. **EKS Service Discovery Role** (`MyCompany-RTBFabric-EKS-Role`) with proper RTB Fabric trust relationship
2. **RTB Fabric Responder Gateway** configured to use the role
3. **Automatic EKS access entry** creation (via `auto_create_access = true`)
4. **Automatic Kubernetes RBAC** creation (via `auto_create_rbac = true`)

## Use Case

This approach is ideal when:
- You want to control role creation and naming
- You want the module to handle EKS access entry creation
- You want the module to handle Kubernetes RBAC creation
- You prefer automation for access management but control over role creation

## Prerequisites

- **EKS Cluster** with access entries support (API or API_AND_CONFIG_MAP authentication mode)
- **Kubernetes Endpoint** resource deployed in the target namespace

## What the Module Will Do

With `auto_create_access = true` and `auto_create_rbac = true`, the module will:

- ✅ **Attach AmazonEKSViewPolicy** to your existing role
- ✅ **Create EKS access entry** for your role
- ✅ **Associate EKS access policy** with namespace scope
- ✅ **Create Kubernetes Role** for endpoint reading
- ✅ **Create Kubernetes RoleBinding** for your role

## What You Need to Provide

- ✅ **AWS credentials** with permissions to create IAM roles and RTB Fabric resources
- ✅ **EKS cluster** with the name specified in the configuration
- ✅ **VPC and networking** resources (update the IDs in main.tf)

## Usage

1. Update the resource IDs in `main.tf` (VPC, subnets, security groups, cluster name)
2. Run:

```bash
terraform init
terraform plan
terraform apply

# View the created role information
terraform output rtb_fabric_eks_role_arn
terraform output rtb_fabric_eks_role_name
```

## What Happens When You Run This

1. **Terraform creates** the `MyCompany-RTBFabric-EKS-Role` with RTB Fabric trust relationship
2. **Module automatically**:
   - Attaches `AmazonEKSViewPolicy` to the role
   - Creates EKS access entry for the role
   - Associates EKS access policy with namespace scope
   - Creates Kubernetes Role for endpoint reading
   - Creates Kubernetes RoleBinding for the role
3. **RTB Fabric service** can now assume the role and access your EKS endpoints

## Benefits

- **Complete Example**: Ready to run with minimal configuration changes
- **Control**: You see exactly how the role is created
- **Automation**: Module handles all EKS and Kubernetes access setup
- **Enterprise Ready**: Demonstrates custom role naming conventions
- **Security**: Role has minimal required permissions with proper trust relationships