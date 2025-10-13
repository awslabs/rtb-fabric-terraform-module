module "rtb_fabric" {
  source = "../../"

  # Requester App
  requester_app = {
    create             = true
    app_name           = "e2e-test-requester"
    description        = "E2E test requester app"
    vpc_id             = "vpc-0eb82f4fa6f0aeea9"
    subnet_ids         = ["subnet-09d3b444cff7c101f", "subnet-006f0d04b2146a333", "subnet-0211339cfd40bd343"]
    security_group_ids = ["sg-03898147ca0749b4b"]
    client_token       = "e2e-test-requester"
    tags = [
      {
        key   = "Environment"
        value = "E2ETest"
      }
    ]
  }

  # EKS Responder App
  responder_app = {
    create             = true
    app_name           = "e2e-test-responder-eks"
    description        = "E2E test EKS responder app"
    vpc_id             = "vpc-0eb82f4fa6f0aeea9"
    subnet_ids         = ["subnet-09d3b444cff7c101f", "subnet-006f0d04b2146a333", "subnet-0211339cfd40bd343"]
    security_group_ids = ["sg-03898147ca0749b4b"]
    port               = 8080
    protocol           = "HTTP"
    dns_name           = "e2e-eks-responder.shapirov-iad1.local"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder"
        endpoints_resource_namespace = "default"
        cluster_name                 = "shapirov-iad1"
        auto_create_access           = true
        auto_create_rbac             = true
        cluster_access_role_arn      = "arn:aws:iam::847454263017:role/shapirov-iad1-EksAccessRole-GmCIdsAV22Pm"
      }
    }

    tags = [
      {
        key   = "Environment"
        value = "E2ETest"
      }
    ]
  }
}

# Second module instance for ASG responder
module "rtb_fabric_asg" {
  source = "../../"

  # ASG Responder App
  responder_app = {
    create             = true
    app_name           = "e2e-test-responder-asg"
    description        = "E2E test ASG responder app"
    vpc_id             = "vpc-0eb82f4fa6f0aeea9"
    subnet_ids         = ["subnet-09d3b444cff7c101f"]
    security_group_ids = ["sg-03898147ca0749b4b"]
    port               = 8080
    protocol           = "HTTP"
    dns_name           = "e2e-asg-responder.shapirov-iad1.local"

    managed_endpoint_configuration = {
      auto_scaling_groups_configuration = {
        auto_scaling_group_name_list = ["eks-EksNodegroupApplication-i7MgONnQJ5ws-a8ccd372-0bd3-e891-d1bb-870726df0fdc"]
        role_arn                     = "arn:aws:iam::847454263017:role/HeimdallAssumeRole"
      }
    }

    tags = [
      {
        key   = "Environment"
        value = "E2ETest"
      }
    ]
  }
}

# Links connecting requester to both responders
module "rtb_fabric_links" {
  source = "../../"

  # Link to EKS responder
  link = {
    create                 = true
    rtb_app_id             = module.rtb_fabric.requester_app_id
    peer_rtb_app_id        = module.rtb_fabric.responder_app_id
    http_responder_allowed = true

    tags = [
      {
        key   = "Environment"
        value = "E2ETest"
      },
      {
        key   = "LinkType"
        value = "EKS"
      }
    ]
  }
}

# Second link module for ASG responder
module "rtb_fabric_links_asg" {
  source = "../../"

  # Link to ASG responder
  link = {
    create                 = true
    rtb_app_id             = module.rtb_fabric.requester_app_id
    peer_rtb_app_id        = module.rtb_fabric_asg.responder_app_id
    http_responder_allowed = true

    tags = [
      {
        key   = "Environment"
        value = "E2ETest"
      },
      {
        key   = "LinkType"
        value = "ASG"
      }
    ]
  }
}