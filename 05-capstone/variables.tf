# =============================================================================
# 05-capstone/variables.tf
# Project-level variables for VDM Cloud Infrastructure Capstone
# =============================================================================

# -----------------------------------------------------------------------------
# PROJECT IDENTIFICATION
# These variables are used across all modules for consistent naming and tagging
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project identifier used in resource naming and tagging - keeps resources organized and identifiable"
  type        = string
  default     = "vdm-capstone"
}

variable "environment" {
  description = "Environment identifier (dev/staging/prod) - controls resource sizing and enables environment-specific configurations"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# -----------------------------------------------------------------------------
# NETWORK CONFIGURATION  
# VPC and subnet settings - adjust CIDR blocks based on network requirements
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for VPC - /16 provides 65,536 IP addresses for growth"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets - hosts load balancers and bastion hosts"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets - hosts application servers and databases"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  description = "AZs for multi-AZ deployment - two zones for high availability"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# -----------------------------------------------------------------------------
# AWS CONFIGURATION
# Provider-level settings
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for all resources - us-east-1 has most services and best Free Tier coverage"
  type        = string
  default     = "us-east-1"
}

# -----------------------------------------------------------------------------
# TAGGING
# Standard tags applied to all resources for cost tracking and organization
# -----------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags applied to all resources - enables cost allocation and resource management"
  type        = map(string)
  default = {
    Project   = "VDM-Cloud-Infrastructure"
    ManagedBy = "Terraform"
    Owner     = "David"
  }
}