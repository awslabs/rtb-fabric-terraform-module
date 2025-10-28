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
    # Include TrustStoreConfiguration if provided
    var.responder_gateway.trust_store_configuration != null ? {
      TrustStoreConfiguration = {
        CertificateAuthorityCertificates = var.responder_gateway.trust_store_configuration.certificate_authority_certificates
      }
    } : {},
    # ManagedEndpointConfiguration - removed TargetGroupsConfiguration support
    var.responder_gateway.managed_endpoint_configuration != null ? {
      ManagedEndpointConfiguration = var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration != null ? {
        AutoScalingGroupsConfiguration = {
          AutoScalingGroupNameList = var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_scaling_group_name_list
          RoleArn                  = var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.role_arn
        }
        } : var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null ? {
        EksEndpointsConfiguration = {
          EndpointsResourceName              = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_name
          EndpointsResourceNamespace         = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_namespace
          ClusterApiServerEndpointUri        = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_endpoint_uri != null ? var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_endpoint_uri : data.aws_eks_cluster.cluster[0].endpoint
          ClusterApiServerCaCertificateChain = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_ca_certificate_chain != null ? var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_ca_certificate_chain : data.aws_eks_cluster.cluster[0].certificate_authority[0].data
          ClusterName                        = var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name
          RoleArn                            = local.eks_service_discovery_role_arn
        }
      } : {}
    } : {}
  ))

  # Ensure EKS resources are created before the gateway
  depends_on = [
    aws_iam_role.eks_service_discovery_role,
    aws_iam_role_policy.eks_service_discovery_role_policy,
    aws_eks_access_entry.rtbfabric,
    kubernetes_role.rtbfabric_endpoint_reader,
    kubernetes_role_binding.rtbfabric_endpoint_reader
  ]
}


