module "rtb_fabric" {
  source = "../../"

  responder_gateway = {
    create             = true
    description        = "terraform responder gateway basic test"
    vpc_id             = "vpc-0eb82f4fa6f0aeea9"
    subnet_ids         = ["subnet-09d3b444cff7c101f"]
    security_group_ids = ["sg-03898147ca0749b4b"]
    port               = 8080
    protocol           = "HTTP"

    tags = [
      {
        key   = "Environment"
        value = "Test"
      }
    ]
  }
}