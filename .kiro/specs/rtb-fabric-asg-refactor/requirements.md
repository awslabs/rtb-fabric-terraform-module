# RTB Fabric ASG Managed Endpoint Refactoring Requirements

## Introduction

This document outlines the requirements for refactoring the RTB Fabric Terraform module to adapt to GA service changes for ASG managed endpoints. Following the same pattern as the EKS managed endpoint refactor, the AWS RTB Fabric service now uses AWS-managed service-linked roles instead of customer-managed HeimdallAssumeRole, requiring updates to the Terraform module's role handling and ASG discovery configuration.

## Glossary

- **Terraform_Module**: The RTB Fabric Terraform module implementation
- **Service_Linked_Role**: AWS-managed AWSServiceRoleForRTBFabric role (managed by AWS, not the module)
- **ASG_Discovery_Role**: Customer-provided IAM role for Auto Scaling Group discovery with trust relationship to RTB Fabric service principals
- **ASG_Managed_Endpoint**: RTB Fabric responder gateway with Auto Scaling Group endpoints configuration
- **Common_Discovery_Module**: Shared module component that provides VPC, subnet, and security group data discovery
- **RTBFabricAsgDiscoveryRole**: Default name for the ASG discovery role when auto-created by the module

## Requirements

### Requirement 1

**User Story:** As a Terraform module maintainer, I want to update the ASG managed endpoint to work with the new GA service role model, so that customers can use the service-linked role approach with ASG discovery.

#### Acceptance Criteria

1. WHEN configuring ASG discovery roles, THE Terraform_Module SHALL require trust relationship to rtbfabric.amazonaws.com and rtbfabric-endpoints.amazonaws.com principals
2. WHEN configuring ASG discovery roles, THE Terraform_Module SHALL require permissions for autoscaling:DescribeAutoScalingGroups, ec2:DescribeInstanceStatus, ec2:DescribeInstances, and ec2:DescribeAvailabilityZones actions
3. WHEN updating resource naming, THE Terraform_Module SHALL replace Heimdall terminology with RTBFabric
4. WHEN removing legacy logic, THE Terraform_Module SHALL remove HeimdallAssumeRole default role creation for ASG endpoints
5. WHEN validating configurations, THE Terraform_Module SHALL verify ASG discovery role has required trust relationships and permissions

### Requirement 2

**User Story:** As a Terraform module user, I want flexible ASG discovery role configuration options, so that I can either provide my own pre-configured role or let the module create one automatically.

#### Acceptance Criteria

1. WHEN providing an existing role, THE Terraform_Module SHALL assume the ASG_Discovery_Role is pre-configured with required permissions
2. WHEN not providing a role, THE Terraform_Module SHALL create a new role with name RTBFabricAsgDiscoveryRole by default
3. WHEN creating a new role, THE Terraform_Module SHALL allow overriding the role name through configuration
4. WHEN creating a new role, THE Terraform_Module SHALL configure trust policy with RTB Fabric service principals
5. WHEN creating a new role, THE Terraform_Module SHALL attach required ASG discovery permissions with region condition

### Requirement 3

**User Story:** As a Terraform module user, I want the module to automatically create ASG discovery roles with proper permissions, so that I don't need to manually configure complex IAM policies.

#### Acceptance Criteria

1. WHEN auto-creating roles, THE Terraform_Module SHALL create trust policy with rtbfabric.amazonaws.com and rtbfabric-endpoints.amazonaws.com principals
2. WHEN auto-creating roles, THE Terraform_Module SHALL attach inline policy with autoscaling:DescribeAutoScalingGroups permission
3. WHEN auto-creating roles, THE Terraform_Module SHALL attach inline policy with ec2:DescribeInstanceStatus, ec2:DescribeInstances, and ec2:DescribeAvailabilityZones permissions
4. WHEN auto-creating roles, THE Terraform_Module SHALL apply region condition restricting permissions to the current AWS region
5. WHEN auto-creating roles, THE Terraform_Module SHALL use RTBFabricAsgDiscoveryRole as the default role name

### Requirement 4

**User Story:** As a Terraform module user, I want the module to leverage the common discovery module for network configuration, so that VPC, subnet, and security group data can be discovered consistently.

#### Acceptance Criteria

1. WHEN using common discovery, THE Common_Discovery_Module SHALL provide VPC ID discovery capabilities
2. WHEN using common discovery, THE Common_Discovery_Module SHALL provide subnet ID discovery capabilities  
3. WHEN using common discovery, THE Common_Discovery_Module SHALL provide security group ID discovery capabilities
4. WHEN configuring ASG endpoints, THE Terraform_Module SHALL require customer to specify subnet IDs that match ASG subnet configuration
5. WHEN configuring ASG endpoints, THE Terraform_Module SHALL require customer to provide Auto Scaling Group name list

### Requirement 5

**User Story:** As a Terraform module user, I want clear validation and error messages for ASG configuration, so that I can quickly identify and fix configuration issues.

#### Acceptance Criteria

1. WHEN validating ASG discovery role, THE Terraform_Module SHALL check trust policy includes RTB Fabric service principals
2. WHEN validating ASG discovery role, THE Terraform_Module SHALL verify required ASG and EC2 permissions are attached
3. WHEN validating ASG configuration, THE Terraform_Module SHALL confirm Auto Scaling Group names are provided
4. WHEN validating network configuration, THE Terraform_Module SHALL verify subnet IDs are specified by customer
5. WHEN validation fails, THE Terraform_Module SHALL provide clear error messages with remediation steps

### Requirement 6

**User Story:** As a Terraform module user, I want the module to handle the transition from legacy Heimdall terminology to RTBFabric for ASG endpoints, so that all resources use consistent naming.

#### Acceptance Criteria

1. WHEN creating ASG discovery roles, THE Terraform_Module SHALL use RTBFabric naming conventions instead of Heimdall
2. WHEN creating IAM policies, THE Terraform_Module SHALL use rtbfabric prefix in policy names
3. WHEN updating variables, THE Terraform_Module SHALL replace heimdall references with rtbfabric in ASG configuration
4. WHEN updating documentation, THE Terraform_Module SHALL use RTB Fabric service terminology for ASG endpoints
5. WHEN creating resources, THE Terraform_Module SHALL ensure consistent RTBFabric naming across all ASG-related components