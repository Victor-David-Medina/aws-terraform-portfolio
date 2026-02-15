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
}
