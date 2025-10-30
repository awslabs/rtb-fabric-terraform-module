# Implementation Plan

## Phase 1: Provider Architecture Modernization

- [ ] 1. Update provider requirements and configuration
- [x] 1.1 Update versions.tf to support external kubernetes provider
  - Add `configuration_aliases = [kubernetes]` to kubernetes provider requirements
  - Ensure backward compatibility with default provider usage
  - _Requirements: 1.1, 2.1_

- [x] 1.2 Remove internal kubernetes provider from eks_helper.tf
  - Remove the `provider "kubernetes"` block from eks_helper.tf
  - Update kubernetes resources to use provided/default provider
  - Remove provider alias references from kubernetes resources
  - _Requirements: 1.1, 2.2_

- [x] 1.3 Update kubernetes resource provider references
  - Remove explicit `provider = kubernetes.eks` from kubernetes_role resource
  - Remove explicit `provider = kubernetes.eks` from kubernetes_role_binding resource
  - Allow resources to use default or passed provider configuration
  - _Requirements: 2.2_

## Phase 2: Variable Interface Simplification

- [ ] 2. Remove cluster_access_role_arn parameter and logic
- [x] 2.1 Update eks_endpoints_configuration variable structure
  - Remove `cluster_access_role_arn` parameter from eks_endpoints_configuration
  - Remove related validation rules for cluster_access_role_arn
  - Update variable documentation to reflect kubernetes provider responsibility
  - _Requirements: 2.1, 2.2_

- [x] 2.2 Remove cluster_access_role_arn logic from eks_helper.tf
  - Remove conditional logic that uses cluster_access_role_arn in provider configuration
  - Simplify kubernetes provider usage to rely on external configuration
  - _Requirements: 2.2_

- [x] 2.3 Update variable validation rules
  - Remove cluster_access_role_arn validation regex
  - Keep other eks_endpoints_configuration validations intact
  - _Requirements: 2.1_

## Phase 3: Validation Simplification

- [ ] 3. Remove kubernetes-specific validations
- [x] 3.1 Disable kubernetes access validation in validation.tf
  - Remove or disable aws_eks_access_entry data source validation
  - Remove kubernetes access validation null_resource
  - Keep IAM trust policy validation only
  - _Requirements: 5.1, 5.2_

- [x] 3.2 Remove kubernetes validation from data.tf
  - Keep data sources disabled (already done)
  - Remove any remaining kubernetes-specific validation logic
  - Focus validation on RTB Fabric IAM concerns only
  - _Requirements: 5.1_

- [ ]* 3.3 Update validation error messages
  - Update error messages to reflect simplified validation scope
  - Remove references to kubernetes access validation
  - _Requirements: 5.5_

## Phase 4: Legacy Cleanup

- [ ] 4. Replace Heimdall terminology with RTBFabric
- [x] 4.1 Update resource names in eks_helper.tf
  - Change kubernetes_role name from "heimdall-*" to "rtbfabric-endpoint-reader"
  - Change kubernetes_role_binding name from "heimdall-*" to "rtbfabric-endpoint-reader"
  - Update resource descriptions and comments
  - _Requirements: 6.1, 6.3_

- [x] 4.2 Update variable names and descriptions
  - Replace any remaining "heimdall" references with "rtbfabric"
  - Update variable descriptions to use RTB Fabric terminology
  - _Requirements: 6.4, 6.5_

- [x] 4.3 Remove HeimdallAssumeRole default role logic
  - Remove any remaining HeimdallAssumeRole creation or references
  - Ensure all role creation uses RTBFabric naming conventions
  - _Requirements: 1.4_

## Phase 5: Example Updates

- [ ] 5. Update all EKS examples with external kubernetes provider
- [x] 5.1 Update examples/responder-gateway-eks-manual/main.tf
  - Add kubernetes provider configuration block
  - Use cluster discovery outputs for provider configuration
  - Remove depends_on from module call (if still present)
  - Add providers block to module call
  - _Requirements: 2.1, 2.2, 4.1_

- [x] 5.2 Update examples/responder-gateway-eks/main.tf
  - Add kubernetes provider configuration block
  - Configure provider with cluster_access_role_arn if specified
  - Add providers block to module call
  - _Requirements: 2.1, 2.2, 4.2_

- [x] 5.3 Update examples/responder-gateway-eks-hybrid/main.tf
  - Add kubernetes provider configuration block
  - Add providers block to module call
  - Remove depends_on from module call
  - _Requirements: 2.1, 2.2, 4.1_

- [x] 5.4 Update examples/e2e-test/main.tf for multi-cluster support
  - Add kubernetes provider configuration for responder cluster
  - Add providers block to module call
  - Demonstrate multi-cluster provider pattern
  - _Requirements: 2.1, 2.2, 4.2_

- [x] 5.5 Update examples/common/outputs.tf
  - Add cluster endpoint and CA certificate outputs
  - Support kubernetes provider configuration in examples
  - _Requirements: 4.2_

## Phase 6: Testing and Validation

- [ ] 6. Validate updated examples and functionality
- [ ] 6.1 Test single-cluster examples
  - Verify terraform plan works for all single-cluster examples
  - Test with different kubernetes provider authentication methods
  - _Requirements: 2.1, 2.2_

- [ ] 6.2 Test multi-cluster example (e2e-test)
  - Verify e2e-test example works with separate kubernetes provider
  - Test provider alias functionality
  - _Requirements: 2.1, 2.2_

- [ ]* 6.3 Test provider flexibility scenarios
  - Test with default kubernetes provider (no alias)
  - Test with aliased kubernetes provider
  - Test with different authentication methods
  - _Requirements: 2.1, 2.2_

- [ ]* 6.4 Validate no regression in RTB Fabric functionality
  - Verify all RTB Fabric resources are created correctly
  - Test role creation and configuration
  - Test EKS access entry and RBAC creation
  - _Requirements: 1.1, 1.2, 1.3, 2.3, 2.4_