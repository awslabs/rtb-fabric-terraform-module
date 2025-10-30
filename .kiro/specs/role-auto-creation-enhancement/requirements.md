# Requirements Document

## Introduction

This feature enhances the RTB Fabric Terraform module to provide consistent role auto-creation capabilities across both EKS and ASG managed endpoint responder gateways. Currently, when users specify a role name, the system assumes the role already exists, which can cause conflicts in E2E testing scenarios where the same role name is used across different clusters with different permissions.

## Glossary

- **RTB_Fabric_Module**: The Terraform module that manages RTB Fabric gateway resources
- **EKS_Managed_Endpoint**: A responder gateway configuration that uses EKS endpoints for service discovery
- **ASG_Managed_Endpoint**: A responder gateway configuration that uses Auto Scaling Groups for service discovery
- **Discovery_Role**: An IAM role that RTB Fabric service assumes to discover endpoints in EKS clusters or ASG instances
- **Auto_Create_Role_Flag**: A boolean configuration parameter that controls whether the module should create the specified role or assume it already exists

## Requirements

### Requirement 1

**User Story:** As a DevOps engineer, I want to specify a custom role name for EKS managed endpoints and have it automatically created, so that I can avoid role naming conflicts across different environments.

#### Acceptance Criteria

1. WHEN an EKS managed endpoint configuration is provided with a role name and auto_create_role is true, THE RTB_Fabric_Module SHALL create the specified role with appropriate EKS discovery permissions
2. WHEN an EKS managed endpoint configuration is provided with a role name and auto_create_role is false, THE RTB_Fabric_Module SHALL assume the role already exists and use it without modification
3. WHEN an EKS managed endpoint configuration is provided without a role name, THE RTB_Fabric_Module SHALL use the default role creation behavior regardless of auto_create_role setting
4. THE RTB_Fabric_Module SHALL validate that auto_create_role is a boolean value when provided for EKS configurations

### Requirement 2

**User Story:** As a DevOps engineer, I want consistent auto_create_role behavior between EKS and ASG managed endpoints, so that I can use the same configuration patterns across different endpoint types.

#### Acceptance Criteria

1. WHEN an ASG managed endpoint configuration is provided with auto_create_role set to true, THE RTB_Fabric_Module SHALL create the specified role with appropriate ASG discovery permissions
2. WHEN an ASG managed endpoint configuration is provided with auto_create_role set to false, THE RTB_Fabric_Module SHALL assume the role already exists and use it without modification
3. THE RTB_Fabric_Module SHALL maintain backward compatibility by defaulting auto_create_role to true for ASG configurations
4. THE RTB_Fabric_Module SHALL validate that auto_create_role is a boolean value when provided for ASG configurations

### Requirement 3

**User Story:** As a DevOps engineer, I want to run E2E tests with custom role names without encountering role already exists errors, so that I can test multiple gateway configurations in the same AWS account.

#### Acceptance Criteria

1. WHEN multiple gateway configurations specify the same role name with auto_create_role set to true, THE RTB_Fabric_Module SHALL handle role creation conflicts gracefully
2. WHEN a role creation fails due to existing role, THE RTB_Fabric_Module SHALL provide clear error messaging indicating the conflict and suggested resolution
3. THE RTB_Fabric_Module SHALL support role creation with unique naming patterns to avoid conflicts in multi-environment scenarios

### Requirement 4

**User Story:** As a DevOps engineer, I want clear documentation and examples of the auto_create_role functionality, so that I can implement it correctly in my infrastructure.

#### Acceptance Criteria

1. THE RTB_Fabric_Module SHALL provide validation rules that clearly indicate when auto_create_role is required or optional
2. THE RTB_Fabric_Module SHALL include example configurations demonstrating both auto_create_role true and false scenarios
3. THE RTB_Fabric_Module SHALL maintain consistent variable naming and structure between EKS and ASG configurations for auto_create_role functionality

### Requirement 5

**User Story:** As a DevOps engineer, I want the auto_create_role feature to work seamlessly with existing role management logic, so that I don't need to refactor existing configurations.

#### Acceptance Criteria

1. THE RTB_Fabric_Module SHALL preserve existing behavior when auto_create_role is not specified
2. THE RTB_Fabric_Module SHALL integrate auto_create_role logic with existing role ARN computation in locals.tf
3. THE RTB_Fabric_Module SHALL ensure role creation conditions in role_management.tf properly account for auto_create_role settings
4. THE RTB_Fabric_Module SHALL maintain all existing role permissions and trust relationships when creating roles through auto_create_role functionality