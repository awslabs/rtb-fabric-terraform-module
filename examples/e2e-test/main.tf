module "rtb_fabric" {
  source = "../../"

  # Requester Gateway
  requester_gateway = {
    create             = true
    description        = "E2E test requester gateway"
    vpc_id             = "vpc-0eb82f4fa6f0aeea9"
    subnet_ids         = ["subnet-09d3b444cff7c101f", "subnet-006f0d04b2146a333", "subnet-0211339cfd40bd343"]
    security_group_ids = ["sg-03898147ca0749b4b"]
    tags = [
      {
        key   = "Environment"
        value = "E2ETest"
      }
    ]
  }

  # EKS Responder Gateway
  responder_gateway = {
    create             = true
    description        = "E2E test EKS responder gateway"
    vpc_id             = "vpc-0eb82f4fa6f0aeea9"
    subnet_ids         = ["subnet-09d3b444cff7c101f", "subnet-006f0d04b2146a333", "subnet-0211339cfd40bd343"]
    security_group_ids = ["sg-03898147ca0749b4b"]
    port               = 8080
    protocol           = "HTTP"

    managed_endpoint_configuration = {
      eks_endpoints_configuration = {
        endpoints_resource_name      = "bidder"
        endpoints_resource_namespace = "default"
        cluster_name                 = "shapirov-iad1"
        # eks_service_discovery_role not specified - will create default role automatically
        auto_create_access           = true
        auto_create_rbac             = true

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

  # ASG Responder Gateway
  responder_gateway = {
    create             = true
    description        = "E2E test ASG responder gateway"
    vpc_id             = "vpc-0eb82f4fa6f0aeea9"
    subnet_ids         = ["subnet-09d3b444cff7c101f"]
    security_group_ids = ["sg-03898147ca0749b4b"]
    port               = 8080
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
    gateway_id             = module.rtb_fabric.requester_gateway_id
    peer_gateway_id        = module.rtb_fabric.responder_gateway_id
    http_responder_allowed = true

    link_log_settings = {
      service_logs = {
        link_service_log_sampling = {
          error_log  = 10
          filter_log = 5
        }
      }
    }

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
    gateway_id             = module.rtb_fabric.requester_gateway_id
    peer_gateway_id        = module.rtb_fabric_asg.responder_gateway_id
    http_responder_allowed = true

    link_log_settings = {
      service_logs = {
        link_service_log_sampling = {
          error_log  = 10
          filter_log = 5
        }
      }
    }

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