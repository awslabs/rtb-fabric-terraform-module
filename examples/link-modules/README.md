# RTB Fabric Link Modules Management Example

This example demonstrates how to add module configuration to an existing RTB Fabric link after it has been accepted by the peer.

Limitations: this approach at the moment does not work for the responder side. Responder is expected to accept link using UI or CLI and configure modules the same way. We are working to address this issue. Requester side module attachment is supported. 

## Important: Link Acceptance Workflow

RTB Fabric links follow a two-phase workflow:

### Phase 1: Link Creation
1. Create the link using the `link` example
2. Link is created in `PENDING` state
3. **Peer must manually accept the link** (no Terraform/CloudFormation support)
4. Link transitions to `ACTIVE` state

### Phase 2: Module Configuration (This Example)
1. After link is `ACTIVE`, you can attach modules
2. Use this example to import the existing link and add module configuration

## Why Split Link and Module Management?

**You cannot attach modules to a link until it is accepted by the peer.** Since there is no Terraform or CloudFormation support to accept links, we split link management into two stages:

1. **Initial Creation** (`examples/link`) - Create link without modules
2. **Module Management** (this example) - Add modules after acceptance

## Prerequisites

1. Link must be created (see `examples/link`)
2. Link must be accepted by peer (manual process)
3. Link status must be `ACTIVE`
4. You need the link ARN

## How to Check Link Status

```bash
# Using AWS CLI
aws rtbfabric get-link --link-id <link-id>

# Or using Terraform output from the link creation
cd ../link
terraform output link_status
```

## Usage

### Step 1: Get Your Link ARN

From your link creation:
```bash
cd ../link
terraform output link_arn
```

### Step 2: Update the Import Block

Edit `main.tf` and replace the placeholder ARN with your actual link ARN:

```hcl
import {
  to = module.rtb_fabric.awscc_rtbfabric_link.link[0]
  id = "arn:aws:rtbfabric:us-east-1:123456789012:gateway/rtb-gw-xxx/link/link-yyy"  # Your ARN here
}
```

### Step 3: Update Gateway IDs

Replace the placeholder gateway IDs with your actual IDs:

```hcl
link = {
  gateway_id      = "rtb-gw-xxx"  # Your gateway ID
  peer_gateway_id = "rtb-gw-yyy"  # Peer gateway ID
  # ...
}
```

### Step 4: Configure Modules

Edit the `module_configuration_list` to add your desired modules:

```hcl
module_configuration_list = [
  {
    name    = "NoBidModule"
    version = "v1"
    module_parameters = {
      no_bid = {
        reason                  = "YourReason"
        reason_code             = 1
        pass_through_percentage = 10.0
      }
    }
  }
]
```

### Step 5: Apply

```bash
terraform init
terraform plan   # Review the changes
terraform apply  # Add modules to the link
```

## Available Modules

### NoBid Module
Filters requests and returns no-bid responses based on criteria.

```hcl
{
  name    = "NoBidModule"
  version = "v1"
  module_parameters = {
    no_bid = {
      reason                  = "TestReason"
      reason_code             = 1
      pass_through_percentage = 10.0
    }
  }
}
```

### OpenRTB Filter Module
Filters OpenRTB requests based on attributes.

```hcl
{
  name    = "OpenRtbFilter"
  version = "v1"
  module_parameters = {
    open_rtb_attribute = {
      filter_type = "INCLUDE"  # or "EXCLUDE"
      filter_configuration = [
        {
          criteria = [
            {
              path   = "$.openrtb.request.context.site.domain"
              values = ["example.com"]
            }
          ]
        }
      ]
      action = {
        no_bid = {
          no_bid_reason_code = 3
        }
      }
      holdback_percentage = 5.0
    }
  }
}
```

## Module Dependencies

If modules have dependencies on each other, use the `depends_on` field:

```hcl
{
  name       = "ModuleB"
  version    = "v1"
  depends_on = ["ModuleA"]  # ModuleB depends on ModuleA
  module_parameters = { ... }
}
```

## Updating Modules

To update module configuration:

1. Edit the `module_configuration_list` in `main.tf`
2. Run `terraform apply`
3. Modules can be updated without recreating the link

## Removing Modules

To remove all modules:

1. Set `module_configuration_list = []` or remove it entirely
2. Run `terraform apply`

## Important Notes

- ⚠️ **Link must be ACTIVE** before adding modules
- ⚠️ **Peer acceptance is manual** - no automation available
- ✅ **Modules can be updated** without recreating the link
- ✅ **Multiple modules** can be attached to a single link
- ⚠️ **Module order matters** if there are dependencies

## Troubleshooting

### Error: Link not found
- Verify the link ARN in the import block is correct
- Check that the link exists: `aws rtbfabric get-link --link-id <link-id>`

### Error: Link is not ACTIVE
- Link must be accepted by peer first
- Check link status: `aws rtbfabric get-link --link-id <link-id>`
- Wait for peer to accept the link

### Error: Module configuration invalid
- Verify module parameters match the schema
- Check module version is supported
- Review module documentation for required fields

## See Also

- [Link Creation Example](../link/) - Create initial link
- [Main README](../../README.md) - Module documentation
- [AWS RTB Fabric Documentation](https://docs.aws.amazon.com/rtbfabric/)
