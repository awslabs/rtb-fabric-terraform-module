# Design Document

## Overview

This design enhances the RTB Fabric Terraform module to provide consistent `auto_create_role` functionality across both EKS and ASG managed endpoint configurations. The enhancement addresses role naming conflicts in multi-environment scenarios by giving users explicit control over whether roles should be created or assumed to exist.

## Architecture

### Current State Analysis

The module currently has inconsistent behavior:
- **ASG Configuration**: Has `auto_create_role` field (defaults to `true`) but logic doesn't fully utilize it
- **EKS Configuration**: Missing `auto_create_role` field entirely
- **Role Creation Logic**: Creates roles when role name is `null`, assumes existence when role name is provided

### Target State

Both EKS and ASG configurations will have consistent `auto_create_role` behavior:
- When `auto_create_role = true` and role name provided: Create the named role
- When `auto_create_role = false` and role name provided: Assume role exists
- When role name is `null`: Use default behavior (create default-named role)

## Components and Interfaces

### 1. Variable Schema Updates

#### EKS Configuration Enhancement
```hcl
eks_endpoints_configuration = optional(object({
  # Existing fields...
  eks_service_discovery_role = optional(string)
  auto_create_role          = optional(bool, true)  # NEW FIELD
  # Other existing fields...
}))
```

#### ASG Configuration (Already Exists)
```hcl
auto_scaling_groups_configuration = optional(object({
  # Existing fields...
  asg_discovery_role = optional(string)
  auto_create_role   = optional(bool, true)  # EXISTING FIELD
}))
```

### 2. Role Creation Logic Enhancement

#### Current Logic Flow
```
if (role_name == null) → create_default_role
else → assume_role_exists
```

#### Enhanced Logic Flow
```
if (role_name == null) → create_default_role
else if (auto_create_role == true) → create_named_role
else → assume_role_exists
```

### 3. Terraform Resource Conditions

#### EKS Role Creation Condition (Enhanced)
```hcl
count = (
  var.responder_gateway.create && 
  var.responder_gateway.managed_endpoint_configuration != null && 
  var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && 
  (
    var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role == null ||
    (
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role != null &&
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_role == true
    )
  )
) ? 1 : 0
```

#### ASG Role Creation Condition (Enhanced)
```hcl
count = (
  var.responder_gateway.create && 
  var.responder_gateway.managed_endpoint_configuration != null && 
  var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration != null && 
  (
    var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role == null ||
    (
      var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role != null &&
      var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_create_role == true
    )
  )
) ? 1 : 0
```

## Data Models

### Configuration Schema Changes

#### Before (EKS)
```hcl
eks_endpoints_configuration = {
  endpoints_resource_name      = string
  endpoints_resource_namespace = string
  cluster_name                 = string
  eks_service_discovery_role   = optional(string)
  # auto_create_role missing
}
```

#### After (EKS)
```hcl
eks_endpoints_configuration = {
  endpoints_resource_name      = string
  endpoints_resource_namespace = string
  cluster_name                 = string
  eks_service_discovery_role   = optional(string)
  auto_create_role            = optional(bool, true)  # NEW
}
```

### Role Name Resolution Logic

```hcl
# Enhanced locals for role name resolution
locals {
  # EKS role creation decision
  should_create_eks_role = (
    var.responder_gateway.managed_endpoint_configuration != null &&
    var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null &&
    (
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role == null ||
      coalesce(var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_role, true)
    )
  )
  
  # ASG role creation decision  
  should_create_asg_role = (
    var.responder_gateway.managed_endpoint_configuration != null &&
    var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration != null &&
    (
      var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role == null ||
      coalesce(var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_create_role, true)
    )
  )
}
```

## Error Handling

### Role Creation Conflicts

When `auto_create_role = true` and the role already exists:
- Terraform will fail with clear error message
- Error message will suggest setting `auto_create_role = false` to use existing role
- No automatic role deletion or overwriting

### Validation Rules

#### EKS Configuration Validation
```hcl
validation {
  condition = (
    var.responder_gateway.managed_endpoint_configuration == null ||
    var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration == null ||
    var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_role == null ||
    can(tobool(var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_role))
  )
  error_message = "auto_create_role must be a boolean value (true or false)"
}
```

#### ASG Configuration Validation
```hcl
validation {
  condition = (
    var.responder_gateway.managed_endpoint_configuration == null ||
    var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration == null ||
    var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_create_role == null ||
    can(tobool(var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_create_role))
  )
  error_message = "auto_create_role must be a boolean value (true or false)"
}
```

## Testing Strategy

### Unit Testing Scenarios

1. **EKS with auto_create_role = true, custom role name**
   - Verify role is created with specified name
   - Verify role has correct permissions and trust policy

2. **EKS with auto_create_role = false, custom role name**
   - Verify no role creation attempt
   - Verify role ARN is computed correctly

3. **ASG with auto_create_role = true, custom role name**
   - Verify role is created with specified name
   - Verify role has correct ASG permissions

4. **ASG with auto_create_role = false, custom role name**
   - Verify no role creation attempt
   - Verify role ARN is computed correctly

5. **Backward Compatibility**
   - Verify existing configurations without auto_create_role work unchanged
   - Verify default behavior when role name is null

### Integration Testing

1. **E2E Test Enhancement**
   - Update e2e-test example to use custom role names with auto_create_role = true
   - Verify no role conflicts in multi-gateway scenarios

2. **Example Updates**
   - Update existing examples to demonstrate auto_create_role usage
   - Add new examples showing both true/false scenarios

### Error Condition Testing

1. **Role Already Exists**
   - Test behavior when auto_create_role = true but role exists
   - Verify clear error messaging

2. **Invalid Configuration**
   - Test validation rules for auto_create_role field
   - Verify appropriate error messages for invalid boolean values

## Implementation Phases

### Phase 1: Core Logic Enhancement
- Update variable schema for EKS configuration
- Enhance role creation conditions in role_management.tf
- Update locals.tf for consistent role name resolution

### Phase 2: Validation and Error Handling
- Add validation rules for auto_create_role fields
- Enhance error messaging for role conflicts
- Update documentation strings

### Phase 3: Examples and Testing
- Update e2e-test example configuration
- Create additional example configurations
- Update README documentation

### Phase 4: Backward Compatibility Verification
- Test existing configurations remain unchanged
- Verify default behavior preservation
- Validate migration path for existing users