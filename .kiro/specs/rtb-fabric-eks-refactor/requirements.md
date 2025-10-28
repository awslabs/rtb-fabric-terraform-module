# RTB Fabric EKS Managed Endpoint Refactoring Requirements

## Introduction

This document outlines the requirements for refactoring the RTB Fabric Terraform module to adapt to GA service changes for EKS managed endpoints. The AWS RTB Fabric service now uses AWS-managed service-linked roles instead of customer-managed HeimdallAssumeRole, requiring updates to the Terraform module's role handling and trust relationship configuration.

## Glossary

- **Terraform_Module**: The RTB Fabric Terraform module implementation
- **Service_Linked_Role**: AWS-managed AWSServiceRoleForRTBFabric role (managed by AWS, not the module)
- **Customer_Role**: Customer-provided IAM role with trust relationship to RTB Fabric service principals
- **EKS_Managed_Endpoint**: RTB Fabric responder gateway with EKS endpoints configuration
- **Auto_Create_Access**: Module feature to automatically create EKS access entries
- **Auto_Create_RBAC**: Module feature to automatically create Kubernetes RBAC resources

## Requirements

### Requirement 1

**User Story:** As a Terraform module maintainer, I want to update the module to work with the new GA service role model, so that customers can use the service-linked role approach.

#### Acceptance Criteria

1. WHEN configuring customer roles, THE Terraform_Module SHALL require trust relationship to rtbfabric.amazonaws.com and rtbfabric-endpoints.amazonaws.com principals
2. WHEN configuring customer roles, THE Terraform_Module SHALL require AmazonEKSViewPolicy attachment
3. WHEN updating resource naming, THE Terraform_Module SHALL replace Heimdall terminology with RTBFabric
4. WHEN removing legacy logic, THE Terraform_Module SHALL remove HeimdallAssumeRole default role creation
5. WHEN validating configurations, THE Terraform_Module SHALL verify customer role has required trust relationships

### Requirement 2

**User Story:** As a Terraform module user, I want two distinct configuration options for EKS managed endpoints, so that I can choose between manual and automatic setup approaches.

#### Acceptance Criteria

1. WHEN using manual setup, THE Customer_Role SHALL be pre-configured with cluster access and RBAC
2. WHEN using manual setup, THE Terraform_Module SHALL validate existing permissions before proceeding
3. WHEN using automatic setup, THE Terraform_Module SHALL configure the customer role with required permissions
4. WHEN using automatic setup, THE Terraform_Module SHALL create EKS access entries if auto_create_access is true
5. WHEN using automatic setup, THE Terraform_Module SHALL create Kubernetes RBAC if auto_create_rbac is true

### Requirement 3

**User Story:** As a Terraform module user, I want the module to automatically configure customer roles when auto-creation is enabled, so that I don't need to manually set up complex permissions.

#### Acceptance Criteria

1. WHEN auto_create_access is true, THE Terraform_Module SHALL add RTB Fabric service principals to customer role trust policy
2. WHEN auto_create_access is true, THE Terraform_Module SHALL attach AmazonEKSViewPolicy to customer role
3. WHEN auto_create_access is true, THE Terraform_Module SHALL create EKS access entry for customer role

### Requirement 4

**User Story:** As a Terraform module user, I want the module to automatically discover private subnets from my EKS cluster, so that RTB Fabric gateways are deployed in the correct network configuration.

#### Acceptance Criteria

1. WHEN discovering VPCs, THE Terraform_Module SHALL require kubernetes.io/cluster/<cluster_name> tag with value "owned" or "shared"
2. WHEN discovering VPCs, THE Terraform_Module SHALL require kubernetes.io/role/internal-elb tag with value "1" to ensure private subnet support
3. WHEN discovering subnets, THE Terraform_Module SHALL filter for subnets tagged with kubernetes.io/cluster/<cluster_name>
4. WHEN discovering subnets, THE Terraform_Module SHALL filter for subnets tagged with kubernetes.io/role/internal-elb="1" to select private subnets
5. WHEN no matching subnets are found, THE Terraform_Module SHALL provide clear error messages about required tags
4. WHEN auto_create_rbac is true, THE Terraform_Module SHALL create namespace-scoped Kubernetes Role
5. WHEN auto_create_rbac is true, THE Terraform_Module SHALL create RoleBinding for customer role

### Requirement 4

**User Story:** As a Terraform module user, I want clear examples showing both configuration approaches, so that I can understand how to set up EKS managed endpoints correctly.

#### Acceptance Criteria

1. WHEN providing examples, THE Terraform_Module SHALL show manual setup with pre-configured role
2. WHEN providing examples, THE Terraform_Module SHALL show automatic setup with role creation
3. WHEN providing examples, THE Terraform_Module SHALL demonstrate proper trust policy configuration
4. WHEN providing examples, THE Terraform_Module SHALL show validation steps for manual setup
5. WHEN providing examples, THE Terraform_Module SHALL use RTBFabric naming conventions

### Requirement 5

**User Story:** As a Terraform module maintainer, I want to validate customer role permissions before making API calls, so that failures are caught early with clear error messages.

#### Acceptance Criteria

1. WHEN validating manual setup, THE Terraform_Module SHALL check customer role trust policy includes RTB Fabric principals
2. WHEN validating manual setup, THE Terraform_Module SHALL verify AmazonEKSViewPolicy is attached to customer role
3. WHEN validating manual setup, THE Terraform_Module SHALL confirm EKS cluster access exists for customer role
4. WHEN validating manual setup, THE Terraform_Module SHALL verify RBAC permissions exist in target namespace
5. WHEN validation fails, THE Terraform_Module SHALL provide clear error messages with remediation steps

### Requirement 6

**User Story:** As a Terraform module user, I want the module to handle the transition from legacy Heimdall terminology to RTBFabric, so that all resources use consistent naming.

#### Acceptance Criteria

1. WHEN creating Kubernetes resources, THE Terraform_Module SHALL use rtbfabric prefix instead of heimdall
2. WHEN creating IAM resources, THE Terraform_Module SHALL use RTBFabric naming conventions
3. WHEN creating EKS access entries, THE Terraform_Module SHALL use rtbfabric-endpoint-reader naming
4. WHEN updating variables, THE Terraform_Module SHALL replace heimdall references with rtbfabric
5. WHEN updating documentation, THE Terraform_Module SHALL use RTB Fabric service terminology