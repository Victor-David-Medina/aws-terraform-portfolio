# modules/compute/variables.tf

variable "project_name" {
  description = "Project identifier used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment identifier (dev/staging/prod)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ASG instance placement"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID to attach to launched instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type - t3.micro qualifies for Free Tier"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum instances - 2 maintains HA across AZs"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum instances - cost cap for demo environment"
  type        = number
  default     = 6

  validation {
    condition     = var.max_size >= 1
    error_message = "max_size must be at least 1."
  }
}

variable "desired_capacity" {
  description = "Initial instance count at deployment"
  type        = number
  default     = 2
}

variable "target_cpu" {
  description = "CPU utilization target for auto scaling (percent)"
  type        = number
  default     = 70.0

  validation {
    condition     = var.target_cpu > 0 && var.target_cpu <= 100
    error_message = "target_cpu must be between 1 and 100."
  }
}
