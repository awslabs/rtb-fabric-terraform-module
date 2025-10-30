# Shared EKS Cluster Discovery Logic
# This file provides reusable data sources and locals for discovering
# VPC, subnets, and security groups based on EKS cluster name

# Get EKS cluster information - this is the source of truth
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# Extract VPC ID directly from EKS cluster configuration
locals {
  cluster_vpc_id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
  cluster_security_group_id = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

# Discover private subnets suitable for internal load balancers in the cluster's VPC
data "aws_subnets" "cluster_subnets" {
  filter {
    name   = "vpc-id"
    values = [local.cluster_vpc_id]
  }

  tags = {
    "kubernetes.io/role/internal-elb" = "1" # Private subnets for internal load balancers
  }
}
