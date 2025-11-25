# RTB Fabric Link Creation Example

This example demonstrates how to create an RTB Fabric link between existing requester and responder gateways.

**⚠️ Important: This example is for initial link creation only.**

For adding module configuration to links, see the [link-modules example](../link-modules/). Modules cannot be attached until the link is accepted by the peer, which is a manual process outside of Terraform.

## Prerequisites

- Existing RTB Fabric requester gateway
- Existing RTB Fabric responder gateway
- Gateway IDs for both gateways

## Configuration

The example creates a link with the following features:

### Link Configuration
- **Customer Provided ID**: Custom identifier for tracking
- **Error Masking**: Masks HTTP 400 errors with NO_BID action
- **Application Logging**: Error and filter log sampling at 20%
- **Tags**: Environment and management tags

## Usage

### Step 1: Update Configuration

Update the gateway IDs in `main.tf`:
```hcl
gateway_id      = "rtb-gw-YOUR-REQUESTER-GATEWAY-ID"
peer_gateway_id = "rtb-gw-YOUR-RESPONDER-GATEWAY-ID"
```

### Step 2: Create the Link

```bash
terraform init
terraform plan
terraform apply
```

### Step 3: Handle http_responder_allowed Limitation (If Used)

**⚠️ Known Limitation:** If you specify `http_responder_allowed` in your configuration, there is a Cloud Control API limitation that will prevent future updates unless you clean up the state.

**Why this happens:** The Cloud Control API doesn't return `http_responder_allowed` in responses, causing the awscc provider to attempt updates on every apply, which fail because the field is immutable.

**Solution:** After creating the link, run the cleanup script once:

```bash
# Option 1: Use the provided script (recommended)
bash ../../scripts/cleanup-link-state.sh

# Option 2: Manual cleanup
LINK_ARN=$(terraform output -raw link_arn)
terraform state rm 'module.rtb_fabric.awscc_rtbfabric_link.link[0]'
terraform import 'module.rtb_fabric.awscc_rtbfabric_link.link[0]' "$LINK_ARN"
terraform plan  # Should show no changes
```

After this one-time cleanup, you can update other link fields (tags, link_log_settings) without errors.

**Note:** If you don't specify `http_responder_allowed`, this cleanup is not needed.

## Outputs

The example provides the following outputs:

- **link_id**: The created link identifier
- **link_arn**: The link's ARN (needed for state cleanup if using http_responder_allowed)
- **link_status**: Current status of the link (will be PENDING until peer accepts)
- **link_direction**: Direction of the link (REQUEST/RESPONSE)
- **link_created_timestamp**: When the link was created
- **link_updated_timestamp**: When the link was last updated

## Resources Created

- 1 RTB Fabric Link with:
  - Error masking configuration
  - Application log sampling
  - Custom tags

## Next Steps

After creating the link:

1. **Wait for peer acceptance** - The link will be in `PENDING` status until the peer accepts it
2. **Check link status** - Use `terraform output link_status` or AWS Console
3. **Add modules** - Once link is `ACTIVE`, use the [link-modules example](../link-modules/) to attach module configuration

## Important Notes

- ⚠️ **Do not use this example to add modules** - Modules cannot be attached until the link is accepted
- ⚠️ **Peer acceptance is manual** - There is no Terraform or CloudFormation support for accepting links
- ⚠️ **http_responder_allowed limitation** - If used, requires one-time state cleanup (see Step 3 above)
- Gateway IDs must follow the pattern `rtb-gw-[a-z0-9-]{1,25}`
- Error and filter log percentages must be between 0 and 100
- Maximum of 200 error masking rules allowed
- Maximum of 50 tags allowed

## Related Examples

- [Link Modules](../link-modules/) - Add module configuration to accepted links
- [Requester Gateway](../requester-gateway/) - Create a requester gateway
- [Responder Gateway Basic](../responder-gateway-basic/) - Create a basic responder gateway
- [E2E Test](../e2e-test/) - Complete end-to-end example with gateways and link