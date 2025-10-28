module "rtb_fabric" {
  source = "../../"

  responder_gateway = {
    create             = true
    description        = "terraform responder gateway asg test"
    vpc_id             = "vpc-0eb82f4fa6f0aeea9"
    subnet_ids         = ["subnet-09d3b444cff7c101f"]
    security_group_ids = ["sg-03898147ca0749b4b"]
    port               = 31234
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      auto_scaling_groups_configuration = {
        auto_scaling_group_name_list = ["eks-EksNodegroupApplication-i7MgONnQJ5ws-a8ccd372-0bd3-e891-d1bb-870726df0fdc"]
        role_arn                     = "arn:aws:iam::847454263017:role/HeimdallAssumeRole"
      }
    }

    tags = [
      {
        key   = "Environment"
        value = "Test"
      }
    ]
  }
}