# 03-modules/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "vdm-terraform-state-a31c60f6"
    key          = "03-modules/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create DEV VPC
module "vpc_dev" {
  source       = "./modules/vpc"
  environment  = "dev"
  project_name = "vdm"
  vpc_cidr     = "10.0.0.0/16"
}

# Create PROD VPC
module "vpc_prod" {
  source       = "./modules/vpc"
  environment  = "prod"
  project_name = "vdm"
  vpc_cidr     = "10.1.0.0/16"
}