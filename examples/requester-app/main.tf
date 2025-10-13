module "rtb_fabric" {
  source = "../../"

  requester_app = {
    create             = true
    app_name           = "terraform-requester-test"
    description        = "terraform requester test"
    vpc_id             = "vpc-04b494ac39886a9cd"
    subnet_ids         = ["subnet-0b81b847b26b34bdc", "subnet-04e9cc18323490792"]
    security_group_ids = ["sg-0e3ede381252b8c74"]
    client_token       = "terraform-requester-test"
    tags = [
      {
        key   = "Environment"
        value = "Gamma"
      }
    ]
  }
}