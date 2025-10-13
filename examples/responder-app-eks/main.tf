module "rtb_fabric" {
  source = "../../"

  responder_app = {
    create             = true
    app_name           = "terraform-responder-eks-test"
    description        = "terraform responder eks test"
    vpc_id             = "vpc-0eb82f4fa6f0aeea9"
    subnet_ids         = ["subnet-09d3b444cff7c101f", "subnet-006f0d04b2146a333", "subnet-0211339cfd40bd343"]
    security_group_ids = ["sg-03898147ca0749b4b"]
    port               = 8080
    protocol           = "HTTP"
    dns_name           = "bidder.shapirov-iad1.local"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder"
        endpoints_resource_namespace = "default"
        cluster_name                 = "shapirov-iad1"
        auto_create_access           = true
        auto_create_rbac             = true
        cluster_access_role_arn      = "arn:aws:iam::847454263017:role/shapirov-iad1-EksAccessRole-GmCIdsAV22Pm"
        # role_arn automatically set by helper
        # cluster_api_server_endpoint_uri automatically retrieved
        # cluster_api_server_ca_certificate_chain automatically retrieved
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