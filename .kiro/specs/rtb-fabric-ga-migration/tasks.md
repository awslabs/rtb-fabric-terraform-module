# Implementation Plan

- [x] 1. Update core Terraform resource files
  - Migrate requester_app.tf to requester.tf with RequesterGateway resource type
  - Migrate responder_app.tf to responder.tf with ResponderGateway resource type  
  - Update link.tf to use GA schema with GatewayId references
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2_

- [x] 1.1 Create new requester.tf with RequesterGateway resource
  - Replace AWS::RTBFabric::RequesterRtbApp with AWS::RTBFabric::RequesterGateway
  - Map AppName to Description field usage
  - Update service permissions from mpofxdevmu to rtbfabric
  - Add support for new read-only attributes (ActiveLinksCount, TotalLinksCount)
  - _Requirements: 1.1, 1.5, 3.1, 3.2, 6.2_

- [x] 1.2 Create new responder.tf with ResponderGateway resource
  - Replace AWS::RTBFabric::ResponderRtbApp with AWS::RTBFabric::ResponderGateway
  - Remove DnsName as input parameter (now read-only DomainName)
  - Add TrustStoreConfiguration support with CertificateAuthorityCertificates
  - Remove TargetGroupsConfiguration option from ManagedEndpointConfiguration
  - Preserve EKS and ASG configuration enhancements
  - _Requirements: 1.2, 1.5, 3.4, 3.5, 6.3, 6.5_

- [x] 1.3 Update link.tf for GA schema compatibility
  - Replace RtbAppId/PeerRtbAppId with GatewayId/PeerGatewayId references
  - Update LinkLogSettings structure from ServiceLogs/AnalyticsLogs to ApplicationLogs
  - Replace LinkServiceLogSampling with LinkApplicationLogSampling
  - Add ModuleConfigurationList support for advanced link configuration
  - _Requirements: 1.3, 4.1, 4.2, 4.3, 4.5, 6.4_

- [x] 2. Update variable definitions and structure
  - Update requester variables to use gateway terminology
  - Update responder variables to remove dns_name input and add trust store support
  - Maintain existing variable structure where possible for consistency
  - _Requirements: 2.5, 3.4, 6.1_

- [x] 2.1 Update variables_requester.tf for gateway terminology
  - Rename app-related variables to gateway-related names
  - Update variable descriptions to reflect RequesterGateway usage
  - Maintain backward-compatible variable structure where possible
  - _Requirements: 2.5, 3.1_

- [x] 2.2 Update variables_responder.tf for gateway terminology and new features
  - Rename app-related variables to gateway-related names
  - Remove responder_dns_name as input variable (now read-only output)
  - Add trust_store_configuration variable support
  - Remove target_groups_configuration option
  - _Requirements: 2.5, 3.4, 6.3_

- [x] 3. Update outputs to reflect new resource attributes
  - Update requester outputs to use GatewayId and DomainName
  - Update responder outputs to use GatewayId and add DomainName output
  - Update link outputs to reflect new attribute names
  - _Requirements: 3.2, 3.3_

- [x] 3.1 Update outputs.tf for requester gateway
  - Replace requester_rtb_app_id with requester_gateway_id
  - Replace requester_endpoint with requester_domain_name
  - Add new read-only outputs for ActiveLinksCount and TotalLinksCount
  - _Requirements: 3.2, 6.2_

- [x] 3.2 Update outputs.tf for responder gateway
  - Replace responder_rtb_app_id with responder_gateway_id
  - Add responder_domain_name as new read-only output
  - Add new read-only outputs for link counts and status information
  - _Requirements: 3.3, 6.3_

- [x] 4. Refactor all example configurations
  - Update complete example to use new module structure
  - Update e2e-test example with functional validation
  - Update link example for new gateway references
  - Update requester-app example configuration
  - Update all responder-app examples (basic, ASG, EKS)
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 4.1 Update examples/complete configuration
  - Refactor to use updated module with RequesterGateway and ResponderGateway
  - Update variable references to new naming conventions
  - Update output references to new attribute names
  - Ensure example can be successfully applied
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 4.2 Update examples/e2e-test configuration
  - Refactor for new resource types and module structure
  - Update test validation logic for new outputs
  - Ensure functional end-to-end testing capability
  - _Requirements: 5.1, 5.4_

- [x] 4.3 Update examples/link configuration
  - Update gateway ID references from RtbAppId to GatewayId
  - Update variable and output references
  - Ensure link creation works with new gateway resources
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 4.4 Update examples/requester-app configuration
  - Refactor to use RequesterGateway resource type
  - Update variable names and references
  - Ensure functional requester gateway creation
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 4.5 Update responder-app examples (basic, ASG, EKS)
  - Refactor all three responder examples for ResponderGateway
  - Remove dns_name input parameters
  - Update managed endpoint configurations
  - Preserve EKS RBAC and access enhancements
  - Ensure all examples are functional
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 6.5_

- [x] 5. Update CloudFormation template
  - Update cfn/requester-app.yml to use RequesterGateway resource type
  - Update resource properties and outputs
  - Ensure template functionality with GA schema
  - _Requirements: 5.5_

- [x] 6. Clean up legacy files and update references
  - Remove old requester_app.tf and responder_app.tf files
  - Update main.tf comments and references
  - Update any remaining legacy references in documentation
  - _Requirements: 2.1, 2.2_

- [ ]* 7. Validate implementation with comprehensive testing
  - Test all examples for successful plan and apply operations
  - Validate resource creation and attribute mapping
  - Test EKS integration preservation
  - Verify new GA features functionality
  - _Requirements: 5.4, 6.5_