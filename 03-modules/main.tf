#main .tf (ROOT folder)
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0 " 
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

#Create DEV VPC
module "vpc_dev" {
  source       = "./modules/vpc"
  environment  = "dev"
  project_name = "vdm"
  vpc_cidr     = "10.0.0.0/16"
}

# Create PROD VPC (same module!)
module "vpc_prod" {
    source       = "./modules/vpc"
    environment  = "prod"
    project_name = "vdm"
    vpc_cidr     = "10.1.0.0/16"
}