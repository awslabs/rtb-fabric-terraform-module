# Requirements Document

## Introduction

This feature addresses the need to make Terraform example configurations more flexible and customer-friendly by extracting hardcoded account-specific values into configurable parameters. Currently, examples contain hardcoded cluster names, IAM role ARNs, VPC IDs, and other account-specific resources that prevent customers from easily running examples in their own AWS accounts.

## Glossary

- **Terraform_Example**: Individual example configurations in the examples/ directory that demonstrate specific RTB Fabric use cases
- **Hardcoded_Value**: Account-specific resource identifiers embedded directly in Terraform configuration files
- **Auto_Discoverable_Value**: Resource identifiers that can be automatically retrieved through AWS APIs or Terraform data sources
- **Configuration_Template**: Example configuration file showing customers how to set their specific values
- **Customer_Configuration**: Actual configuration file containing customer's specific values, excluded from version control

## Requirements

### Requirement 1

**User Story:** As a customer, I want to easily customize Terraform examples for my AWS account, so that I can deploy RTB Fabric resources without modifying hardcoded values in the example code.

#### Acceptance Criteria

1. WHEN examining Terraform examples, THE Terraform_Example SHALL NOT contain hardcoded account-specific resource identifiers
2. WHEN a value cannot be auto-discovered, THE Terraform_Example SHALL expose it as a configurable variable in terraform.tfvars
3. THE Terraform_Example SHALL limit configurable variables to: cluster_name, kubernetes_auth_role_arn, vpc_id (only if not using auto-discovery), subnet_ids (only if not using auto-discovery), security_group_ids (only if not using auto-discovery)
4. THE Terraform_Example SHALL NOT extract application-level parameters such as namespace, endpoint names, descriptions, ports, or protocols as these represent reasonable defaults for the example use case
5. WHEN a value can be auto-discovered, THE Terraform_Example SHALL use data sources or module outputs to retrieve it dynamically
6. WHEN providing examples, THE Terraform_Example SHALL include both terraform.tfvars.example template and terraform.tfvars with current working values
7. WHERE customer-specific values are needed, THE Terraform_Example SHALL provide a .gitignore file to exclude actual customer configurations from version control

### Requirement 2

**User Story:** As a customer, I want clear guidance on which values I need to configure, so that I can quickly set up examples without guessing what needs to be changed.

#### Acceptance Criteria

1. THE Terraform_Example SHALL provide a terraform.tfvars.example file showing the limited set of configurable parameters
2. THE Terraform_Example SHALL provide a terraform.tfvars file with current working values to maintain existing functionality
3. THE Configuration_Template SHALL include comments explaining each parameter's purpose and when it should be used
4. THE Configuration_Template SHALL distinguish between required parameters (cluster_name) and optional parameters (role ARNs, network overrides)
5. THE Configuration_Template SHALL show example values for cluster names and role ARNs
6. WHERE parameters have validation rules, THE Terraform_Example SHALL include clear error messages for invalid inputs

### Requirement 3

**User Story:** As a customer, I want examples to work with minimal configuration, so that I can focus on understanding RTB Fabric functionality rather than complex setup.

#### Acceptance Criteria

1. WHEN only cluster_name is provided, THE Terraform_Example SHALL successfully deploy using auto-discovery for VPC, subnets, and security groups
2. THE Terraform_Example SHALL prioritize auto-discovery over manual configuration for network resources
3. WHERE auto-discovery is used, THE Terraform_Example SHALL provide outputs showing discovered VPC, subnet, and security group values
4. THE Terraform_Example SHALL use sensible defaults for application-level parameters (port, protocol, endpoint names)
5. WHEN auto-discovery fails, THE Terraform_Example SHALL provide clear error messages indicating what manual network configuration is needed
6. WHERE kubernetes_auth_role_arn is not provided, THE Terraform_Example SHALL use current AWS credentials for cluster access

### Requirement 4

**User Story:** As a maintainer, I want a consistent approach across all examples, so that customers have a predictable experience regardless of which example they use.

#### Acceptance Criteria

1. THE Terraform_Example SHALL follow a standardized variable naming convention across all examples
2. THE Terraform_Example SHALL use consistent file structure for configuration management
3. THE Configuration_Template SHALL follow the same format and commenting style across examples
4. WHERE similar functionality exists, THE Terraform_Example SHALL use shared modules or data sources
5. THE Terraform_Example SHALL include consistent .gitignore patterns for customer configuration files

### Requirement 5

**User Story:** As a maintainer, I want existing examples to continue functioning without modification, so that current deployments and CI/CD processes are not disrupted.

#### Acceptance Criteria

1. THE Terraform_Example SHALL include a terraform.tfvars file with current hardcoded values to maintain existing functionality
2. THE Terraform_Example SHALL continue to deploy successfully using the provided terraform.tfvars without any code changes
3. WHERE examples currently use specific cluster names, THE terraform.tfvars SHALL contain those exact cluster names
4. WHERE examples currently use specific role ARNs, THE terraform.tfvars SHALL contain those exact role ARNs
5. THE Terraform_Example SHALL maintain all current outputs and resource configurations

### Requirement 6

**User Story:** As a customer, I want to understand what values are being used in my deployment, so that I can verify the configuration matches my expectations.

#### Acceptance Criteria

1. THE Terraform_Example SHALL output all significant configuration values used during deployment
2. WHERE auto-discovery is used, THE Terraform_Example SHALL output the discovered values with clear labels
3. WHERE manual configuration overrides auto-discovery, THE Terraform_Example SHALL clearly indicate which values were manually specified
4. THE Terraform_Example SHALL provide outputs showing whether values came from auto-discovery or manual configuration
5. WHEN deployment completes, THE Terraform_Example SHALL output key resource identifiers for reference