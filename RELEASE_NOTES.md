# Release v0.2.2 - Improved Tags UX & IAM Role Propagation Fix

## What's New

### Simplified Tags Format (Breaking Change)

Tags now use the standard Terraform map format instead of CloudFormation list format, making the module more intuitive and consistent with other AWS Terraform modules.

**Before:**
```hcl
tags = [
  {
    key   = "Environment"
    value = "Production"
  }
]
```

**After:**
```hcl
tags = {
  Environment = "Production"
  Team        = "Platform"
}
```

The module automatically converts the map format to the CloudFormation format required by the awscc provider internally.

### IAM Role Propagation Fix

Added automatic 10-second delay after IAM role creation to prevent "access denied" errors when RTB Fabric service attempts to assume newly created roles. This fixes the issue where the first `terraform apply` would fail with a 403 error, requiring a second apply.

**Technical Details:**
- Added `time_sleep` resources for both EKS and ASG discovery roles
- Ensures IAM roles are fully propagated globally before use
- Only applies when `auto_create_role = true`

## Breaking Changes

### Tags Format Change

If you're using tags in your configuration, you must update them from list format to map format:

```hcl
# Old format (no longer supported)
responder_gateway = {
  tags = [
    { key = "Environment", value = "Production" }
  ]
}

# New format (required)
responder_gateway = {
  tags = {
    Environment = "Production"
  }
}
```

This applies to:
- `requester_gateway.tags`
- `responder_gateway.tags`
- `link.tags`

## Bug Fixes

- Fixed IAM eventual consistency issue causing 403 errors on first apply
- Improved error handling for role assumption failures

## Upgrade Guide

### From v0.2.1 to v0.2.2

1. **Update module source:**
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module?ref=v0.2.2"
  # Your configuration
}
```

2. **Update tags format** (if using tags):
```hcl
# Change from list format to map format
tags = {
  Environment = "Production"
  Owner       = "TeamA"
}
```

3. **Run terraform plan** to verify changes
4. **Apply changes** - first apply will be faster and more reliable

# Release v0.2.1 - Versions pinned to the tested set

## What's New

- Versions pinned
- release GitHub Action

# Release v0.2.0 - Link Module Management & IAM Role Improvements

## What's New

### Link Module Management
We've added better support for managing link modules with a new workflow that aligns with AWS RTB Fabric's link acceptance process.

**New Example: link-modules**
- Demonstrates how to add module configuration to existing, accepted links
- Includes examples for NoBid and OpenRTB Filter modules
- Clear documentation of the two-phase workflow (create → accept → configure modules)

**Why the split?** Links must be accepted by the peer before modules can be attached. Since there's no Terraform or CloudFormation support for link acceptance, we've separated link creation from module management for a cleaner workflow.

### Improved IAM Role Management

**ASG Discovery Role Enhancements**
- Added `auto_create_role` support for ASG managed endpoints (matching EKS functionality)
- Custom role naming for ASG discovery roles
- Automatic IAM policy propagation delays to prevent race conditions
- Better validation and error messages

**Time Provider Integration**
- Added `time_sleep` resource to handle IAM policy propagation
- Prevents "access denied" errors during resource creation
- Ensures roles are fully propagated before use

### Bug Fixes & Improvements

**Cloud Control API Workarounds**
- Documented `http_responder_allowed` field limitation
- Added cleanup script (`scripts/cleanup-link-state.sh`) for state management
- Clear instructions for handling immutable field issues

**Documentation Updates**
- Fixed incorrect module configuration schema in examples
- Added comprehensive troubleshooting section
- Clarified provider configuration requirements
- Added note about responder-side module management limitation

**Provider Configuration**
- Added explicit provider configuration for e2e-test example
- Documented when provider blocks are needed vs optional
- Better AWS credentials troubleshooting

## Breaking Changes

None - this release is fully backward compatible with v0.1.0.

## Known Limitations

1. **http_responder_allowed**: Cloud Control API doesn't return this field, requiring one-time state cleanup after link creation if used
2. **Responder-side modules**: Module configuration is currently only supported from the requester side (AWS is working on this)
3. **Link acceptance**: No Terraform/CloudFormation support for accepting links - must be done manually

## Upgrade Guide

### From v0.1.0 to v0.2.2

Update your module source and convert tags to map format:

```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module?ref=v0.2.2"
  
  # Update tags from list to map format
  requester_gateway = {
    tags = {
      Environment = "Production"
    }
  }
}
```

### If Using http_responder_allowed

If you're setting `http_responder_allowed` in your link configuration, run the cleanup script once after upgrading:

```bash
bash scripts/cleanup-link-state.sh
```

### If Adding Modules to Existing Links

Use the new `link-modules` example to add module configuration to links that have been accepted by peers.

## What's Next

We're tracking these improvements for future releases:
- Automated handling of `http_responder_allowed` state management
- Support for responder-side module management (pending AWS API support)
- Additional module type examples
- Enhanced validation and error messages

## Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed technical changes.

---

**Questions or Issues?** Please open an issue on GitHub or refer to our [troubleshooting guide](README.md#troubleshooting).
