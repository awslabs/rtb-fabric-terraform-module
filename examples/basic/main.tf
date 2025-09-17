module "rtb_fabric" {
  source = "../../"

  app_name           = "test02"
  description        = "test02"
  vpc_id             = "vpc-00108ced4ec00636b"
  subnet_ids         = ["subnet-0e656d1ce3ba7d025", "subnet-0efd6f0427bfe0a3b"]
  security_group_ids = ["sg-050ebc8a5303a9337"]
  client_token       = "test02"
}
