# =============================================================================
# modules/vpc/variables.tf
# VDM Cloud Infrastructure - VPC Module Variables
#
# All variables include descriptions explaining their purpose
# Defaults provided for dev environment - override for staging/prod
# =============================================================================

# -----------------------------------------------------------------------------
# PROJECT IDENTIFICATION
# Used for consistent resource naming across the infrastructure
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project identifier for resource naming - enables filtering resources by project in AWS Console and cost reports"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment identifier (dev/staging/prod) - controls naming and enables environment-based resource filtering"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# -----------------------------------------------------------------------------
# NETWORK CONFIGURATION
# CIDR blocks sized for growth while avoiding IP conflicts
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for VPC - /16 provides 65,536 IPs for future growth without re-architecting"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of AZs for multi-AZ deployment - two zones provides high availability"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets - /24 provides 254 usable IPs per subnet for load balancers and bastion hosts"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets - /24 provides 254 usable IPs per subnet for application servers and databases"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# -----------------------------------------------------------------------------
# TAGGING
# Common tags merged with resource-specific tags for cost allocation
# -----------------------------------------------------------------------------

variable "common_tags" {
  description = "Tags applied to all resources - enables cost tracking, ownership identification, and compliance reporting"
  type        = map(string)
  default = {
    Project   = "VDM-Cloud-Infrastructure"
    ManagedBy = "Terraform"
    Owner     = "David"
  }
}
