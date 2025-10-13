module "rtb_fabric" {
  source = "../../"

  requester_app = {
    create             = true
    app_name           = "my-requester"
    description        = "Requester app"
    vpc_id             = "vpc-xxx"
    subnet_ids         = ["subnet-xxx"]
    security_group_ids = ["sg-xxx"]
    client_token       = "token"
  }

  responder_app = {
    create               = true
    app_name             = "my-responder"
    description          = "Responder app"
    vpc_id               = "vpc-xxx"
    subnet_ids           = ["subnet-xxx"]
    security_group_ids   = ["sg-xxx"]
    port                 = 8080
    protocol             = "HTTPS"
    dns_name             = "app.example.com"
    ca_certificate_chain = "LS0tLS..."
  }

  link = {
    create          = true
    rtb_app_id      = module.rtb_fabric.requester_app_id
    peer_rtb_app_id = module.rtb_fabric.responder_app_id
  }
}