# =============================================================================
# 05-capstone/providers.tf
# Provider and backend configuration for VDM Cloud Infrastructure Capstone
# =============================================================================

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ---------------------------------------------------------------------------
  # Remote State — S3 Backend (see ADR-005: docs/adr/ADR-005-remote-state.md)
  #
  # The S3 bucket is created by backend-setup/. You must bootstrap it first:
  #   cd backend-setup && terraform init && terraform apply && cd ..
  #
  # Then uncomment the block below and run:
  #   terraform init -migrate-state
  #
  # Uses use_lockfile (Terraform 1.10+) instead of DynamoDB for state locking.
  # See backend-setup/README.md for the full bootstrap walkthrough.
  # ---------------------------------------------------------------------------
  # backend "s3" {
  #   bucket       = "vdm-terraform-state"
  #   key          = "capstone/terraform.tfstate"
  #   region       = "us-east-1"
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "Terraform"
    }
  }
}
