# Requirements Document

## Introduction

This document outlines the requirements for migrating the AWS RTB Fabric Terraform module from the legacy private registry API to the new GA (Generally Available) public API. The migration involves updating resource types, attribute mappings, provider usage, and file structure to align with the new AWS RTB Fabric service schema. Note that the current GA schemas represent the initial release and additional resources may be added in future service updates.

## Glossary

- **RTB_Fabric_Module**: The Terraform module that provisions AWS RTB Fabric resources
- **Legacy_API**: The previous private registry API using AWS::RTBFabric::RequesterRtbApp and AWS::RTBFabric::ResponderRtbApp
- **GA_API**: The new Generally Available API using AWS::RTBFabric::RequesterGateway and AWS::RTBFabric::ResponderGateway
- **AWSCC_Provider**: The AWS Cloud Control API provider for Terraform
- **Resource_Schema**: The CloudFormation resource type definitions in JSON format
- **Gateway_Resources**: The new RequesterGateway and ResponderGateway resources replacing RtbApp resources
- **Link_Resource**: The connection resource between gateways (updated schema)

## Requirements

### Requirement 1

**User Story:** As a Terraform module maintainer, I want to update the module to use the new GA API resource types, so that users can provision RTB Fabric resources using the officially supported service.

#### Acceptance Criteria

1. WHEN updating resource types, THE RTB_Fabric_Module SHALL replace AWS::RTBFabric::RequesterRtbApp with AWS::RTBFabric::RequesterGateway
2. WHEN updating resource types, THE RTB_Fabric_Module SHALL replace AWS::RTBFabric::ResponderRtbApp with AWS::RTBFabric::ResponderGateway
3. WHEN updating resource types, THE RTB_Fabric_Module SHALL update AWS::RTBFabric::Link to use the new GA schema
4. WHEN updating providers, THE RTB_Fabric_Module SHALL continue using the AWSCC_Provider without JSON encoding
5. WHEN updating service permissions, THE RTB_Fabric_Module SHALL replace mpofxdevmu service permissions with rtbfabric service permissions

### Requirement 2

**User Story:** As a Terraform module user, I want the module file structure to reflect the new resource naming, so that the code organization matches the updated service terminology.

#### Acceptance Criteria

1. WHEN renaming files, THE RTB_Fabric_Module SHALL rename requester_app.tf to requester.tf
2. WHEN renaming files, THE RTB_Fabric_Module SHALL rename responder_app.tf to responder.tf
3. WHEN renaming files, THE RTB_Fabric_Module SHALL rename variables_requester.tf to variables_requester.tf (keep existing name)
4. WHEN renaming files, THE RTB_Fabric_Module SHALL rename variables_responder.tf to variables_responder.tf (keep existing name)
5. WHEN updating variable names, THE RTB_Fabric_Module SHALL replace app-related variable names with gateway-related names

### Requirement 3

**User Story:** As a Terraform module user, I want the resource attributes to be correctly mapped from legacy to GA schema, so that all functionality is preserved during migration.

#### Acceptance Criteria

1. WHEN mapping requester attributes, THE RTB_Fabric_Module SHALL map AppName to Description field usage pattern
2. WHEN mapping requester attributes, THE RTB_Fabric_Module SHALL map RtbAppId to GatewayId in outputs
3. WHEN mapping requester attributes, THE RTB_Fabric_Module SHALL map RtbAppEndpoint to DomainName in outputs
4. WHEN mapping responder attributes, THE RTB_Fabric_Module SHALL remove DnsName requirement and make it read-only as DomainName
5. WHEN mapping responder attributes, THE RTB_Fabric_Module SHALL update ManagedEndpointConfiguration to remove TargetGroupsConfiguration option

### Requirement 4

**User Story:** As a Terraform module user, I want the Link resource to use the updated schema, so that link creation works with the new gateway resources.

#### Acceptance Criteria

1. WHEN updating link references, THE RTB_Fabric_Module SHALL replace RtbAppId with GatewayId
2. WHEN updating link references, THE RTB_Fabric_Module SHALL replace PeerRtbAppId with PeerGatewayId
3. WHEN updating link logging, THE RTB_Fabric_Module SHALL replace ServiceLogs and AnalyticsLogs with ApplicationLogs structure
4. WHEN updating link logging, THE RTB_Fabric_Module SHALL replace LinkServiceLogSampling with LinkApplicationLogSampling
5. WHEN updating link features, THE RTB_Fabric_Module SHALL add support for ModuleConfigurationList

### Requirement 5

**User Story:** As a Terraform module user, I want all examples to be updated to use the new resource types and attributes, so that I can reference working configurations.

#### Acceptance Criteria

1. WHEN updating examples, THE RTB_Fabric_Module SHALL refactor all example configurations to use the updated module with new resource types
2. WHEN updating examples, THE RTB_Fabric_Module SHALL update all variable references to use new naming conventions
3. WHEN updating examples, THE RTB_Fabric_Module SHALL update all output references to use new attribute names
4. WHEN updating examples, THE RTB_Fabric_Module SHALL ensure all examples are functional and can be successfully applied
5. WHEN updating CloudFormation templates, THE RTB_Fabric_Module SHALL update cfn/requester-app.yml to use new resource types

### Requirement 6

**User Story:** As a Terraform module user, I want full support for all new GA schema attributes and features, so that I can leverage the complete functionality of the RTB Fabric service.

#### Acceptance Criteria

1. WHEN implementing new attributes, THE RTB_Fabric_Module SHALL support all new attributes defined in the GA schema
2. WHEN implementing RequesterGateway, THE RTB_Fabric_Module SHALL support ActiveLinksCount and TotalLinksCount read-only attributes
3. WHEN implementing ResponderGateway, THE RTB_Fabric_Module SHALL support TrustStoreConfiguration with CertificateAuthorityCertificates
4. WHEN implementing Link resource, THE RTB_Fabric_Module SHALL support ModuleConfigurationList for advanced link configuration
5. WHEN preserving EKS enhancements, THE RTB_Fabric_Module SHALL maintain automatic RBAC and access features for EKS endpoints configuration

### Requirement 7

**User Story:** As a Terraform module user, I want the module to strictly comply with the GA schema validation rules, so that all resources are created correctly and no legacy attributes remain.

#### Acceptance Criteria

1. WHEN validating Link variables, THE RTB_Fabric_Module SHALL remove all legacy service_logs and analytics_logs references and use only ApplicationLogs structure
2. WHEN validating ModuleConfigurationList, THE RTB_Fabric_Module SHALL use exact GA schema property names with PascalCase (NoBid, OpenRtbAttribute)
3. WHEN validating LinkLogSettings, THE RTB_Fabric_Module SHALL enforce required ApplicationLogs.LinkApplicationLogSampling with ErrorLog and FilterLog fields
4. WHEN validating module parameters, THE RTB_Fabric_Module SHALL add comprehensive validation rules for all ModuleConfigurationList constraints
5. WHEN removing legacy references, THE RTB_Fabric_Module SHALL ensure no RtbApp, mpofxdevmu, or other legacy API references remain in any files