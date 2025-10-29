resource "aws_cloudcontrolapi_resource" "responder_gateway" {
  count = var.responder_gateway.create ? 1 : 0

  type_name = "AWS::RTBFabric::ResponderGateway"

  desired_state = jsonencode(merge(
    {
      # Required fields - must not be null
      VpcId            = var.responder_gateway.vpc_id
      SubnetIds        = var.responder_gateway.subnet_ids
      SecurityGroupIds = var.responder_gateway.security_group_ids
      Port             = var.responder_gateway.port
      Protocol         = var.responder_gateway.protocol
      Tags = var.responder_gateway.tags != null ? [for tag in var.responder_gateway.tags : {
        Key   = tag.key
        Value = tag.value
      }] : []
    },
    # Include Description if provided
    var.responder_gateway.description != null ? {
      Description = var.responder_gateway.description
    } : {},
    # Include DomainName if provided
    var.responder_gateway.domain_name != null ? {
      DomainName = var.responder_gateway.domain_name
    } : {},
    # Include TrustStoreConfiguration if provided
    var.responder_gateway.trust_store_configuration != null ? {
      TrustStoreConfiguration = {
        CertificateAuthorityCertificates = var.responder_gateway.trust_store_configuration.certificate_authority_certificates
      }
    } : {},
    # ManagedEndpointConfiguration - computed in locals to avoid conditional type issues
    length(keys(local.managed_endpoint_configuration)) > 0 ? {
      ManagedEndpointConfiguration = local.managed_endpoint_configuration
    } : {}
  ))

  # Ensure required resources are created before the gateway
  # All potential dependencies are listed - Terraform automatically handles conditional resources
  depends_on = [
    aws_iam_role.eks_service_discovery_role,
    aws_iam_role_policy.eks_service_discovery_role_policy,
    aws_iam_role.asg_service_discovery_role,
    aws_iam_role_policy.asg_service_discovery_role_policy,
    aws_eks_access_entry.rtbfabric,
    kubernetes_role.rtbfabric_endpoint_reader,
    kubernetes_role_binding.rtbfabric_endpoint_reader
  ]
}


