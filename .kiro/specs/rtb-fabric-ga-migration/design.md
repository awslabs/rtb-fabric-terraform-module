# Design Document

## Overview

This design document outlines the migration strategy for updating the AWS RTB Fabric Terraform module from the legacy private registry API to the new GA public API. The migration involves comprehensive updates to resource types, attribute mappings, file structure, and examples while preserving existing functionality and adding support for new GA features.

## Architecture

### Current Architecture (Legacy)
```
RTB Fabric Module
├── requester_app.tf (AWS::RTBFabric::RequesterRtbApp)
├── responder_app.tf (AWS::RTBFabric::ResponderRtbApp)  
├── link.tf (AWS::RTBFabric::Link - legacy schema)
├── variables_requester.tf
├── variables_responder.tf
└── examples/ (using legacy resource types)
```

### Target Architecture (GA)
```
RTB Fabric Module
├── requester.tf (AWS::RTBFabric::RequesterGateway)
├── responder.tf (AWS::RTBFabric::ResponderGateway)
├── link.tf (AWS::RTBFabric::Link - GA schema)
├── variables_requester.tf (updated for gateway)
├── variables_responder.tf (updated for gateway)
└── examples/ (refactored for new module)
```

## Components and Interfaces

### 1. Requester Gateway Component

**Legacy → GA Mapping:**
- Resource Type: `AWS::RTBFabric::RequesterRtbApp` → `AWS::RTBFabric::RequesterGateway`
- Service Namespace: `mpofxdevmu` → `rtbfabric`
- ID Attribute: `RtbAppId` → `GatewayId`
- Endpoint Attribute: `RtbAppEndpoint` → `DomainName`
- Name Attribute: `AppName` → Use in `Description` field

**New GA Attributes:**
- `ActiveLinksCount` (read-only)
- `TotalLinksCount` (read-only)
- Updated status enum: `RequesterGatewayStatus`

### 2. Responder Gateway Component

**Legacy → GA Mapping:**
- Resource Type: `AWS::RTBFabric::ResponderRtbApp` → `AWS::RTBFabric::ResponderGateway`
- Service Namespace: `mpofxdevmu` → `rtbfabric`
- ID Attribute: `RtbAppId` → `GatewayId`
- DNS Attribute: `DnsName` (required input) → `DomainName` (read-only output)
- Certificate: `CaCertificateChain` → `TrustStoreConfiguration.CertificateAuthorityCertificates`

**Removed Features:**
- `TargetGroupsConfiguration` option in `ManagedEndpointConfiguration` (GA schema only supports AutoScalingGroupsConfiguration and EksEndpointsConfiguration)

**New GA Attributes:**
- `TrustStoreConfiguration` with certificate authority certificates
- `ActiveLinksCount`, `TotalLinksCount`, `InboundLinksCount` (read-only)
- Updated status enum: `ResponderGatewayStatus`

### 3. Link Component

**Legacy → GA Mapping:**
- Gateway References: `RtbAppId`/`PeerRtbAppId` → `GatewayId`/`PeerGatewayId`
- Status: `LinkState` → `LinkStatus` (updated enum values)
- Logging Structure: Complete restructure from `ServiceLogs`/`AnalyticsLogs` to `ApplicationLogs`

**New GA Features:**
- `ModuleConfigurationList` for advanced link configuration
- Updated logging sampling structure
- Enhanced error masking capabilities

## Data Models

### Variable Structure Updates

**Requester Variables:**
```hcl
# Legacy pattern
variable "requester_app_name" { ... }
variable "create_requester_app" { ... }

# GA pattern  
variable "requester_gateway_name" { ... }  # Maps to description
variable "create_requester_gateway" { ... }
```

**Responder Variables:**
```hcl
# Legacy pattern (required input)
variable "responder_dns_name" { ... }

# GA pattern (read-only output)
# Remove dns_name as input variable
# Add trust_store_configuration support
```

### Output Structure Updates

**Requester Outputs:**
```hcl
# Legacy
output "requester_rtb_app_id" { ... }
output "requester_endpoint" { ... }

# GA
output "requester_gateway_id" { ... }
output "requester_domain_name" { ... }
```

**Responder Outputs:**
```hcl
# Legacy
output "responder_rtb_app_id" { ... }

# GA  
output "responder_gateway_id" { ... }
output "responder_domain_name" { ... }  # New read-only
```

## Error Handling

### Migration Validation
- Schema validation against new GA resource definitions
- Attribute mapping validation to ensure no data loss
- Provider compatibility checks for awscc provider usage

### Runtime Error Handling
- Graceful handling of removed attributes (e.g., TargetGroupsConfiguration)
- Clear error messages for unsupported legacy configurations
- Validation of required GA attributes

## Testing Strategy

### Unit Testing
- Variable validation for new schema requirements
- Attribute mapping correctness
- Resource type updates

### Integration Testing  
- End-to-end example deployment validation
- Cross-resource dependency testing (gateway → link relationships)
- EKS integration preservation testing

### Example Validation
- All examples must successfully plan and apply
- Functional testing of created resources
- Validation of outputs and resource relationships

## Implementation Phases

### Phase 1: Core Resource Migration
1. Update resource types in terraform files
2. Map legacy attributes to GA schema
3. Update variable definitions
4. Update output definitions

### Phase 2: Enhanced Features
1. Add support for new GA attributes
2. Implement TrustStoreConfiguration
3. Add ModuleConfigurationList support
4. Update logging structure

### Phase 3: Examples and Documentation
1. Refactor all examples to use updated module
2. Update CloudFormation templates
3. Validate functional examples
4. Update documentation

## Preserved Enhancements

### EKS Integration
- Maintain automatic RBAC configuration
- Preserve automatic access features
- Keep cluster endpoint and certificate auto-discovery
- Maintain role ARN defaulting logic

### Auto Scaling Groups
- Preserve existing ASG configuration patterns
- Maintain role ARN handling
- Keep existing validation logic

## Breaking Changes Documentation

### Removed Features
- `TargetGroupsConfiguration` in ResponderGateway ManagedEndpointConfiguration (GA schema only supports AutoScalingGroupsConfiguration and EksEndpointsConfiguration)
- `DnsName` as input parameter (now read-only as `DomainName`)
- Legacy service permissions (`mpofxdevmu` → `rtbfabric`)

### Changed Attributes
- Resource type names (RtbApp → Gateway)
- ID attribute names (RtbAppId → GatewayId)
- Status enum values
- Logging structure reorganization

### File Renames
- `requester_app.tf` → `requester.tf`
- `responder_app.tf` → `responder.tf`