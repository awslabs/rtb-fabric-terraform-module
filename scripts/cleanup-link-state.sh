#!/bin/bash
set -e

# Script to clean up link state after creation
# This removes http_responder_allowed from state to prevent update errors

echo "=========================================="
echo "RTB Fabric Link State Cleanup Script"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "terraform.tfstate" ] && [ ! -d ".terraform" ]; then
    echo "Error: This doesn't appear to be a Terraform directory"
    echo "Please run this script from your Terraform root module directory"
    exit 1
fi

# Get the link ARN from outputs
echo "Step 1: Getting link ARN from Terraform outputs..."
LINK_ARN=$(terraform output -raw link_arn 2>/dev/null)

if [ -z "$LINK_ARN" ]; then
    echo "Error: Could not get link_arn from terraform output"
    echo "Make sure the link has been created and link_arn output exists"
    exit 1
fi

echo "Found link ARN: $LINK_ARN"
echo ""

# Remove from state
echo "Step 2: Removing link from Terraform state..."
terraform state rm 'module.rtb_fabric.awscc_rtbfabric_link.link[0]'
echo ""

# Reimport
echo "Step 3: Reimporting link from AWS..."
terraform import 'module.rtb_fabric.awscc_rtbfabric_link.link[0]' "$LINK_ARN"
echo ""

# Verify
echo "Step 4: Verifying state is clean..."
echo "Running terraform plan to check for changes..."
echo ""

if terraform plan -detailed-exitcode > /dev/null 2>&1; then
    echo "✓ Success! State is clean, no changes detected"
    echo "You can now run terraform apply to update other fields without errors"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 2 ]; then
        echo "⚠ Warning: Terraform plan shows changes"
        echo "This might be expected if you have other pending changes"
        echo "Run 'terraform plan' to review"
    else
        echo "✗ Error: terraform plan failed"
        exit 1
    fi
fi

echo ""
echo "=========================================="
echo "Cleanup complete!"
echo "=========================================="
