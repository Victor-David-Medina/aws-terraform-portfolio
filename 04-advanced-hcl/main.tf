# 04-advanced-hcl/main.tf
# COMPLETE FILE - workspaces example

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#Different S3 CIDR based on workspace
locals {
  workspace_config = {
    default = "10.0.0.0/16"
    dev     = "10.1.0.0/16"
    prod    = "10.2.0.0/16"
  }
  vpc_cidr = lookup(local.workspace_config, terraform.workspace, "10.0.0.0/16")
}
resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr

  tags = {
    Name        = "vdm-${terraform.workspace}-vpc"
    Environment = terraform.workspace
  }
}

output "workspace" {
  value = terraform.workspace
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}