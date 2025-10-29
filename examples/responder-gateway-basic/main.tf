module "rtb_fabric" {
  source = "../../"

  responder_gateway = {
    create             = true
    description        = "terraform responder gateway basic test"
    vpc_id             = "vpc-01a185e1a42ffbb7b"
    subnet_ids         = ["subnet-05f406bce380d07e8"]
    security_group_ids = ["sg-0a79869648d9b8540"]
    port               = 31234
    protocol           = "HTTP"
    domain_name        = "k8s-default-biddernl-4999a78091-c16b86b98466e062.elb.us-east-1.amazonaws.com"
    tags = [
      {
        key   = "Environment"
        value = "Test"
      }
    ]
  }
}