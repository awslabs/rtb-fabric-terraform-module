# Implementation Plan

- [-] 1. Update variable structure for ASG managed endpoints
  - Remove `role_arn` field from `auto_scaling_groups_configuration`
  - Add `asg_discovery_role` field (optional string for role name)
  - Add `auto_create_role` field (optional bool, default true)
  - Update variable validation rules for new structure
  - Add deprecation warnings for any legacy field usage
  - _Requirements: 1.4, 2.2, 2.3_

- [ ] 2. Create ASG discovery role management infrastructure
- [ ] 2.1 Add local values for ASG discovery role computation
  - Create `asg_discovery_role_name` local following EKS pattern
  - Create `asg_discovery_role_arn` local for ARN computation
  - Add conditional logic for role name selection (provided vs default)
  - _Requirements: 2.2, 2.3, 3.5_

- [ ] 2.2 Add default role name variable
  - Create `rtbfabric_asg_discovery_role_name` variable with default "RTBFabricAsgDiscoveryRole"
  - Add validation for IAM role name format
  - _Requirements: 2.3, 3.5_

- [ ] 2.3 Create ASG discovery role resource
  - Add conditional `aws_iam_role` resource for ASG discovery role creation
  - Configure trust policy with rtbfabric.amazonaws.com and rtbfabric-endpoints.amazonaws.com principals
  - Add appropriate tags and description
  - _Requirements: 1.1, 2.4, 3.1_

- [ ] 2.4 Create ASG discovery permissions policy
  - Add `aws_iam_role_policy` resource with ASG and EC2 permissions
  - Include autoscaling:DescribeAutoScalingGroups, ec2:DescribeInstanceStatus, ec2:DescribeInstances, ec2:DescribeAvailabilityZones actions
  - Apply region condition restricting permissions to current AWS region
  - _Requirements: 1.2, 3.2, 3.3, 3.4_

- [ ] 3. Update responder gateway resource configuration
- [ ] 3.1 Modify CloudControlAPI resource for ASG endpoints
  - Update `aws_cloudcontrolapi_resource.responder_gateway` to use computed ASG discovery role ARN
  - Replace direct `role_arn` usage with `local.asg_discovery_role_arn`
  - Add proper dependencies for ASG discovery role creation
  - _Requirements: 1.3, 1.4_

- [ ] 3.2 Update resource dependencies
  - Add ASG discovery role and policy to `depends_on` list
  - Ensure proper creation order for ASG-related resources
  - _Requirements: 2.4, 3.1_

- [ ] 4. Add validation for manual setup mode
- [ ] 4.1 Create validation data sources
  - Add `aws_iam_role` data source for existing ASG discovery role validation
  - Add `aws_iam_role_policy` data source for permissions validation
  - Add conditional logic based on manual vs automatic setup
  - _Requirements: 5.1, 5.2_

- [ ] 4.2 Implement validation checks
  - Validate trust policy includes RTB Fabric service principals
  - Verify required ASG and EC2 permissions are attached
  - Add clear error messages for validation failures
  - _Requirements: 5.1, 5.2, 5.5_

- [ ] 5. Update example configuration
- [ ] 5.1 Migrate ASG example to new structure
  - Update `examples/responder-gateway-asg/main.tf` to use new configuration format
  - Remove `role_arn` field and add `asg_discovery_role` configuration
  - Demonstrate automatic role creation approach
  - _Requirements: 6.1, 6.2, 6.3_

- [ ] 5.2 Add example documentation
  - Update example README with new configuration approach
  - Show both manual and automatic setup patterns
  - Include trust policy configuration examples
  - _Requirements: 6.4, 6.5_

- [ ]* 5.3 Create additional example for manual setup
  - Add example showing pre-configured ASG discovery role usage
  - Demonstrate validation and error handling scenarios
  - _Requirements: 5.5_

- [ ] 6. Clean up legacy terminology and improve error handling
- [ ] 6.1 Update resource naming consistency
  - Ensure all ASG-related resources use RTBFabric naming conventions
  - Replace any remaining Heimdall references with RTBFabric
  - _Requirements: 1.3, 6.1, 6.2_

- [ ] 6.2 Enhance error messages and validation
  - Add comprehensive error messages for common configuration issues
  - Include remediation guidance in error messages
  - Add validation for ASG configuration parameters
  - _Requirements: 5.3, 5.4, 5.5_

- [ ]* 6.3 Add comprehensive testing
  - Create test cases for automatic role creation
  - Add tests for manual role setup validation
  - Test various validation failure scenarios
  - _Requirements: 5.1, 5.2, 5.5_