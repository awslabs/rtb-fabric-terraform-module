# EKS Service Discovery Role Configuration
# This single role is assumed by RTB Fabric service and has all necessary permissions

# Create EKS Service Discovery Role when not provided or when auto_create_role is true
resource "aws_iam_role" "eks_service_discovery_role" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && (
    var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role == null ||
    (
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role != null &&
      coalesce(var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_role, true) == true
    )
  ) ? 1 : 0

  name = local.eks_service_discovery_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "rtbfabric.amazonaws.com",
            "rtbfabric-endpoints.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  description = "RTB Fabric EKS Service Discovery Role - assumed by RTB Fabric service for EKS access"

  tags = {
    Name                        = local.eks_service_discovery_role_name
    Purpose                     = "RTB Fabric EKS Service Discovery"
    ManagedBy                   = "Terraform"
    RTBFabricManagedEndpoint    = "true"
  }
}



# Attach EKS cluster describe permissions to the service discovery role
resource "aws_iam_role_policy" "eks_service_discovery_role_policy" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration != null && (
    var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role == null ||
    (
      var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.eks_service_discovery_role != null &&
      coalesce(var.responder_gateway.managed_endpoint_configuration.eks_endpoints_configuration.auto_create_role, true) == true
    )
  ) ? 1 : 0

  name = "${local.eks_service_discovery_role_name}Policy"
  role = local.eks_service_discovery_role_name

  depends_on = [aws_iam_role.eks_service_discovery_role]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = data.aws_eks_cluster.cluster[0].arn
      }
    ]
  })
}

# ASG Service Discovery Role Configuration
# This single role is assumed by RTB Fabric service and has all necessary permissions for ASG discovery

# Create ASG Service Discovery Role when not provided or when auto_create_role is true
resource "aws_iam_role" "asg_service_discovery_role" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration != null && (
    var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role == null ||
    (
      var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role != null &&
      coalesce(var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_create_role, true) == true
    )
  ) ? 1 : 0

  name = local.asg_discovery_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "rtbfabric.amazonaws.com",
            "rtbfabric-endpoints.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  description = "RTB Fabric ASG Service Discovery Role - assumed by RTB Fabric service for ASG access"

  tags = {
    Name                        = local.asg_discovery_role_name
    Purpose                     = "RTB Fabric ASG Service Discovery"
    ManagedBy                   = "Terraform"
    RTBFabricManagedEndpoint    = "true"
  }
}

# Attach ASG discovery permissions to the service discovery role
resource "aws_iam_role_policy" "asg_service_discovery_role_policy" {
  count = var.responder_gateway.create && var.responder_gateway.managed_endpoint_configuration != null && var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration != null && (
    var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role == null ||
    (
      var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.asg_discovery_role != null &&
      coalesce(var.responder_gateway.managed_endpoint_configuration.auto_scaling_groups_configuration.auto_create_role, true) == true
    )
  ) ? 1 : 0

  name = "${local.asg_discovery_role_name}Policy"
  role = local.asg_discovery_role_name

  depends_on = [aws_iam_role.asg_service_discovery_role]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AsgEndpointsIpDiscovery"
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstances",
          "ec2:DescribeAvailabilityZones"
        ]
        Resource = "*"
      }
    ]
  })
}
