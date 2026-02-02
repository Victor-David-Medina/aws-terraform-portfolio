# 04-advanced-hcl/main.tf
# COMPLETE FILE — for_each example

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

# Map of subnets with meaningful names
variable "subnets" {
  default = {
    web = "10.0.1.0/24"
    app = "10.0.2.0/24"
    db  = "10.0.3.0/24"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "vdm-foreach-demo-vpc" }
}

# for_each creates subnets with NAMED keys
resource "aws_subnet" "named" {
  for_each = var.subnets

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value

  tags = {
    Name = "vdm-${each.key}-subnet"
    Tier = each.key
  }
}

output "subnet_details" {
  value = {
    for k, v in aws_subnet.named : k => {
      id   = v.id
      cidr = v.cidr_block
    }
  }
}