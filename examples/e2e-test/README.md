# End-to-End Test Example

Comprehensive test that creates a complete RTB Fabric setup with:
- 1 Requester App
- 1 EKS Responder App (with auto RBAC/access)
- 1 ASG Responder App
- 2 Links connecting requester to both responders

## Resources Created

- **Requester App**: `e2e-test-requester`
- **EKS Responder**: `e2e-test-responder-eks` (connects to shapirov-iad1 cluster)
- **ASG Responder**: `e2e-test-responder-asg` (uses Application nodegroup ASG)
- **EKS Link**: Connects requester to EKS responder
- **ASG Link**: Connects requester to ASG responder

## Usage

### Manual
```bash
terraform init
terraform plan
terraform apply

# View outputs after deployment
terraform output

# Get specific output
terraform output requester_app_id

terraform destroy
```

### Using Makefile
```bash
# Deploy all resources
make deploy

# Destroy all resources  
make destroy

# Full end-to-end test (deploy + destroy)
make e2e-test
```

## Test Validation

After deployment, verify:
1. All RTB app IDs are generated
2. Links are in ACTIVE state
3. EKS access entries created
4. RBAC resources created in cluster
5. ASG endpoints discovered

## Cleanup

Always run `make destroy` or `terraform destroy` to clean up test resources and avoid charges.