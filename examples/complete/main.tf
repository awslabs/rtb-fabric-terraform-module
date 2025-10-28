module "rtb_fabric" {
  source = "../../"

  requester_gateway = {
    create             = true
    description        = "Requester gateway"
    vpc_id             = "vpc-xxx"
    subnet_ids         = ["subnet-xxx"]
    security_group_ids = ["sg-xxx"]
  }

  responder_gateway = {
    create               = true
    description          = "Responder gateway"
    vpc_id               = "vpc-xxx"
    subnet_ids           = ["subnet-xxx"]
    security_group_ids   = ["sg-xxx"]
    port                 = 8080
    protocol             = "HTTPS"
    ca_certificate_chain = "LS0tLS..."  # Maps to trust_store_configuration
  }

  link = {
    create          = true
    gateway_id      = module.rtb_fabric.requester_gateway_id
    peer_gateway_id = module.rtb_fabric.responder_gateway_id
    link_log_settings = {
      service_logs = {
        link_service_log_sampling = {
          error_log  = 10
          filter_log = 5
        }
      }
    }
  }
}