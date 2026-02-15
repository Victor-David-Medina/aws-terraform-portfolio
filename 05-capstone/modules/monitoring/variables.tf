# modules/monitoring/variables.tf

variable "project_name" {
  description = "Project identifier used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment identifier (dev/staging/prod)"
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group name to monitor"
  type        = string
}

variable "cpu_high_threshold" {
  description = "CPU percentage that triggers high utilization alarm"
  type        = number
  default     = 70
}

variable "cpu_low_threshold" {
  description = "CPU percentage that triggers low utilization alarm"
  type        = number
  default     = 30
}
