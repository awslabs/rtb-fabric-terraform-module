resource "awscc_rtb_fabric_requester_rtb_app" "this" {
  app_name           = var.app_name
  description        = var.description
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  client_token       = var.client_token
}
