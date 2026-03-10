# =============================================================================
# 05-capstone/main.tf
# VDM Cloud Infrastructure Capstone - Production VPC Stack
#
# This is the root module that composes all infrastructure components.
# Each module handles a specific concern: networking, security, compute,
# monitoring, threat detection, and cost governance.
#
# Provider and backend configuration: see providers.tf
# =============================================================================

# -----------------------------------------------------------------------------
# NETWORKING
# Multi-AZ VPC with public/private subnet segmentation (see ADR-001)
# -----------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  common_tags          = var.common_tags
}

# -----------------------------------------------------------------------------
# SECURITY GROUPS
# Tiered security: web (public-facing) → db (private, web-tier only)
# -----------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

# -----------------------------------------------------------------------------
# COMPUTE
# Auto Scaling Group across private subnets for elastic capacity (see ADR-002)
# -----------------------------------------------------------------------------
module "compute" {
  source = "./modules/compute"

  project_name       = var.project_name
  environment        = var.environment
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security.web_sg_id
}

# -----------------------------------------------------------------------------
# MONITORING
# CloudWatch alarms for operational visibility into scaling events
# -----------------------------------------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  asg_name     = module.compute.asg_name
}

# -----------------------------------------------------------------------------
# SECURITY MONITORING
# GuardDuty threat detection - analyzes VPC Flow Logs and CloudTrail
# -----------------------------------------------------------------------------
module "security_monitoring" {
  source = "./modules/security-monitoring"

  project_name = var.project_name
  environment  = var.environment
}

# -----------------------------------------------------------------------------
# COST GOVERNANCE
# Budget alerts to prevent cost surprises in demo environment
# -----------------------------------------------------------------------------
module "cost" {
  source = "./modules/cost"

  project_name = var.project_name
  environment  = var.environment
  alert_emails = var.alert_emails
}
