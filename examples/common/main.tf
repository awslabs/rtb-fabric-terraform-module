# Shared EKS Cluster Discovery Logic
# This file provides reusable data sources and locals for discovering
# VPC, subnets, and security groups based on EKS cluster name

# Discover VPC tagged with kubernetes.io/cluster/<cluster_name> (owned or shared)
# Also requires kubernetes.io/role/internal-elb=1 to ensure private subnet support
data "aws_vpcs" "cluster_vpcs" {
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "*" # Matches both "owned" and "shared"
  }
}

# Get the first VPC (there should typically be only one)
locals {
  cluster_vpc_id = data.aws_vpcs.cluster_vpcs.ids[0]
}

# Discover private subnets tagged with kubernetes.io/cluster/<cluster_name> (owned or shared)
# Filters for private subnets suitable for internal load balancers
data "aws_subnets" "cluster_subnets" {
  filter {
    name   = "vpc-id"
    values = [local.cluster_vpc_id]
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "*" # Matches both "owned" and "shared"
    "kubernetes.io/role/internal-elb"           = "1" # Private subnets for internal load balancers
  }
}

# Get EKS cluster to find its security group
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# Use the cluster's security group
locals {
  cluster_security_group_id = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}
