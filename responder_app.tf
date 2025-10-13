resource "aws_cloudcontrolapi_resource" "responder_app" {
  count = var.responder_app.create ? 1 : 0

  type_name = "AWS::RTBFabric::ResponderRtbApp"

  desired_state = jsonencode(merge(
    {
      AppName          = var.responder_app.app_name
      Description      = var.responder_app.description
      VpcId            = var.responder_app.vpc_id
      SubnetIds        = var.responder_app.subnet_ids
      SecurityGroupIds = var.responder_app.security_group_ids
      Port             = var.responder_app.port
      Protocol         = var.responder_app.protocol
      DnsName          = var.responder_app.dns_name

      Tags = [for tag in var.responder_app.tags : {
        Key   = tag.key
        Value = tag.value
      }]
    },
    var.responder_app.client_token != null ? { ClientToken = var.responder_app.client_token } : {},

    var.responder_app.ca_certificate_chain != null ? { CaCertificateChain = var.responder_app.ca_certificate_chain } : {},
    var.responder_app.managed_endpoint_configuration != null ? {
      ManagedEndpointConfiguration = var.responder_app.managed_endpoint_configuration.auto_scaling_groups_configuration != null ? {
        AutoScalingGroupsConfiguration = {
          AutoScalingGroupNameList = var.responder_app.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_scaling_group_name_list
          RoleArn                  = var.responder_app.managed_endpoint_configuration.auto_scaling_groups_configuration.role_arn
        }
        } : var.responder_app.managed_endpoint_configuration.target_groups_configuration != null ? {
        TargetGroupsConfiguration = {
          TargetGroupArns = var.responder_app.managed_endpoint_configuration.target_groups_configuration.target_group_arns
        }
        } : var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration != null ? {
        EksEndpointsConfiguration = {
          EndpointsResourceName              = var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_name
          EndpointsResourceNamespace         = var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.endpoints_resource_namespace
          ClusterApiServerEndpointUri        = var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_endpoint_uri != null ? var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_endpoint_uri : data.aws_eks_cluster.cluster[0].endpoint
          ClusterApiServerCaCertificateChain = var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_ca_certificate_chain != null ? var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.cluster_api_server_ca_certificate_chain : data.aws_eks_cluster.cluster[0].certificate_authority[0].data
          ClusterName                        = var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.cluster_name
          RoleArn                            = var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.role_arn != null ? var.responder_app.managed_endpoint_configuration.eks_endpoints_configuration.role_arn : local.eks_role_arn
        }
      } : {}
    } : {}
  ))
}