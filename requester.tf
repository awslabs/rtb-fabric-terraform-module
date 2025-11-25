# RTB Fabric Requester Gateway using awscc provider
resource "awscc_rtbfabric_requester_gateway" "requester_gateway" {
  count = var.requester_gateway.create ? 1 : 0

  # Required attributes
  vpc_id             = var.requester_gateway.vpc_id
  subnet_ids         = var.requester_gateway.subnet_ids
  security_group_ids = var.requester_gateway.security_group_ids

  # Optional attributes - pass through directly
  description = var.requester_gateway.description
  tags        = var.requester_gateway.tags
}


