# Provider Configuration for E2E Test

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

# AWS Provider - region configured via terraform.tfvars or environment
provider "aws" {
  region = var.aws_region
}

# AWS Cloud Control Provider
provider "awscc" {
  region = var.aws_region
}
