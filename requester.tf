resource "aws_cloudcontrolapi_resource" "requester_gateway" {
  count = var.requester_gateway.create ? 1 : 0

  type_name = "AWS::RTBFabric::RequesterGateway"

  desired_state = jsonencode(merge(
    {
      # Required fields - must not be null
      VpcId            = var.requester_gateway.vpc_id
      SubnetIds        = var.requester_gateway.subnet_ids
      SecurityGroupIds = var.requester_gateway.security_group_ids
      Tags = var.requester_gateway.tags != null ? [for tag in var.requester_gateway.tags : {
        Key   = tag.key
        Value = tag.value
      }] : []
    },
    # Include Description if provided
    var.requester_gateway.description != null ? {
      Description = var.requester_gateway.description
    } : {}
  ))
}


