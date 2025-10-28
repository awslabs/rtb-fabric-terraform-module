# Implementation Plan

- [x] 1. Update variable definitions and validation
  - Replace HeimdallAssumeRole references with customer role configuration
  - Add customer_role_arn parameter to eks_endpoints_configuration
  - Update variable validation rules for new role model
  - Remove legacy heimdall variable references
  - _Requirements: 1.4, 6.4_

- [x] 2. Refactor role management logic in locals.tf
  - Remove default_heimdall_role_arn logic
  - Update eks_role_arn computation to use customer-provided role
  - Add validation for customer role ARN format
  - _Requirements: 1.4, 1.1_

- [x] 3. Update EKS access management in eks_helper.tf
  - Replace heimdall resource names with rtbfabric naming
  - Update EKS access entry creation to use customer role ARN
  - Modify access policy association to use customer role
  - Update conditional logic for auto_create_access flag
  - _Requirements: 2.4, 3.3, 6.1, 6.3_

- [x] 4. Update Kubernetes RBAC resources
  - Rename kubernetes_role from heimdall-endpoint-reader to rtbfabric-endpoint-reader
  - Rename kubernetes_role_binding to use rtbfabric naming
  - Update role subject to use customer role ARN
  - Modify conditional logic for auto_create_rbac flag
  - _Requirements: 2.5, 3.4, 3.5, 6.1_

- [x] 5. Add customer role validation data sources
  - Create data source to fetch customer role details
  - Add validation for trust policy principals (rtbfabric.amazonaws.com, rtbfabric-endpoints.amazonaws.com)
  - Add validation for AmazonEKSViewPolicy attachment
  - Implement validation checks for manual setup mode
  - _Requirements: 1.5, 2.2, 5.1, 5.2_

- [x] 6. Implement role configuration for automatic mode
  - Add IAM role policy attachment for AmazonEKSViewPolicy
  - Create trust policy configuration for RTB Fabric service principals
  - Add conditional resource creation based on auto_create_access flag
  - _Requirements: 3.1, 3.2, 1.1, 1.2_

- [x] 7. Add comprehensive error handling and validation
  - Implement validation checks with clear error messages
  - Add remediation guidance for common configuration issues
  - Create validation for EKS cluster access in manual mode
  - Add RBAC permission validation for manual setup
  - _Requirements: 5.3, 5.4, 5.5_

- [x] 8. Update responder.tf resource configuration
  - Ensure RoleArn in EksEndpointsConfiguration uses customer role
  - Update conditional logic to handle customer role ARN properly
  - Verify integration with updated locals.tf logic
  - _Requirements: 1.1, 2.3_

- [x] 9. Migrate existing examples to new role model
  - Update examples that use eks_endpoints_configuration
  - Create example showing manual setup with pre-configured role
  - Create example showing automatic setup with role configuration
  - Add example trust policy configurations
  - _Requirements: 4.1, 4.2, 4.3, 4.5_

- [x] 10. Update documentation and variable descriptions
  - Replace Heimdall terminology with RTB Fabric in all descriptions
  - Update variable documentation to reflect new role model
  - Add guidance for trust policy configuration
  - Document migration path from HeimdallAssumeRole
  - _Requirements: 6.5, 4.4_