# Implementation Plan

- [x] 1. Add auto_create_role field to EKS configuration schema
  - Add auto_create_role field to eks_endpoints_configuration in variables.tf
  - Set default value to true for backward compatibility
  - Add validation rule for boolean type checking
  - _Requirements: 1.4, 2.4, 5.1_

- [x] 2. Enhance role creation logic in role_management.tf
  - [x] 2.1 Update EKS role creation condition to include auto_create_role logic
    - Modify aws_iam_role.eks_service_discovery_role count condition
    - Include auto_create_role = true check when role name is provided
    - _Requirements: 1.1, 1.2_
  
  - [x] 2.2 Update ASG role creation condition to include auto_create_role logic
    - Modify aws_iam_role.asg_service_discovery_role count condition
    - Include auto_create_role = true check when role name is provided
    - _Requirements: 2.1, 2.2_
  
  - [x] 2.3 Update EKS role policy creation condition
    - Modify aws_iam_role_policy.eks_service_discovery_role_policy count condition
    - Ensure policy creation aligns with role creation logic
    - _Requirements: 1.1, 5.3_
  
  - [x] 2.4 Update ASG role policy creation condition
    - Modify aws_iam_role_policy.asg_service_discovery_role_policy count condition
    - Ensure policy creation aligns with role creation logic
    - _Requirements: 2.1, 5.3_

- [x] 3. Update locals.tf for enhanced role name resolution
  - [x] 3.1 Add role creation decision logic
    - Create should_create_eks_role local variable
    - Create should_create_asg_role local variable
    - _Requirements: 5.2_
  
  - [x] 3.2 Enhance role name resolution logic
    - Update eks_service_discovery_role_name logic to account for auto_create_role
    - Update asg_discovery_role_name logic to account for auto_create_role
    - _Requirements: 1.3, 2.3, 5.2_

- [x] 4. Add comprehensive validation rules
  - [x] 4.1 Add EKS auto_create_role validation
    - Add validation block for EKS auto_create_role boolean type
    - Include clear error message for invalid values
    - _Requirements: 1.4, 4.1_
  
  - [x] 4.2 Add ASG auto_create_role validation
    - Add validation block for ASG auto_create_role boolean type
    - Include clear error message for invalid values
    - _Requirements: 2.4, 4.1_

- [x] 5. Update e2e-test example configuration
  - [x] 5.1 Add auto_create_role configuration to EKS responder
    - Set auto_create_role = true in e2e-test example
    - Add custom role name to demonstrate functionality
    - _Requirements: 3.1, 4.2_
  
  - [x] 5.2 Update example documentation
    - Add comments explaining auto_create_role usage
    - Document both true and false scenarios
    - _Requirements: 4.2, 4.3_

- [ ]* 6. Create additional example configurations
  - [ ]* 6.1 Create example with auto_create_role = false
    - Demonstrate usage with existing roles
    - Show both EKS and ASG configurations
    - _Requirements: 4.2_
  
  - [ ]* 6.2 Create multi-environment example
    - Show role naming patterns to avoid conflicts
    - Demonstrate auto_create_role in different scenarios
    - _Requirements: 3.3, 4.2_

- [ ]* 7. Write unit tests for new functionality
  - [ ]* 7.1 Test EKS role creation with auto_create_role = true
    - Verify role creation when custom name provided
    - Verify correct permissions and trust policy
    - _Requirements: 1.1_
  
  - [ ]* 7.2 Test EKS role assumption with auto_create_role = false
    - Verify no role creation attempt
    - Verify correct role ARN computation
    - _Requirements: 1.2_
  
  - [ ]* 7.3 Test ASG role creation with auto_create_role = true
    - Verify role creation when custom name provided
    - Verify correct permissions and trust policy
    - _Requirements: 2.1_
  
  - [ ]* 7.4 Test ASG role assumption with auto_create_role = false
    - Verify no role creation attempt
    - Verify correct role ARN computation
    - _Requirements: 2.2_
  
  - [ ]* 7.5 Test backward compatibility scenarios
    - Verify existing configurations work unchanged
    - Test default behavior when role name is null
    - _Requirements: 5.1_

- [x] 8. Update validation.tf with enhanced error handling
  - Add validation for role creation conflicts
  - Enhance error messages to suggest auto_create_role = false for existing roles
  - _Requirements: 3.2, 4.1_

- [ ]* 9. Update documentation and README
  - [ ]* 9.1 Update variable documentation
    - Document auto_create_role field for both EKS and ASG
    - Include usage examples and best practices
    - _Requirements: 4.2, 4.3_
  
  - [ ]* 9.2 Update README with auto_create_role examples
    - Add section explaining role auto-creation feature
    - Include code examples for both true and false scenarios
    - _Requirements: 4.2_