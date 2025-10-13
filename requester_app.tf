resource "aws_cloudcontrolapi_resource" "requester_app" {
  count = var.requester_app.create ? 1 : 0

  type_name = "AWS::RTBFabric::RequesterRtbApp"

  desired_state = jsonencode({
    AppName          = var.requester_app.app_name
    Description      = var.requester_app.description
    VpcId            = var.requester_app.vpc_id
    SubnetIds        = var.requester_app.subnet_ids
    SecurityGroupIds = var.requester_app.security_group_ids
    ClientToken      = var.requester_app.client_token
    Tags = [for tag in var.requester_app.tags : {
      Key   = tag.key
      Value = tag.value
    }]
  })
}