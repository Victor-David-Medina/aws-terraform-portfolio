# modules/cost/variables.tf

variable "project_name" {
  description = "Project identifier used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment identifier (dev/staging/prod)"
  type        = string
}

variable "budget_limit" {
  description = "Monthly budget limit in USD"
  type        = string
  default     = "100"
}

variable "alert_emails" {
  description = "Email addresses for budget alert notifications"
  type        = list(string)
  default     = ["v.davidmedina@gmail.com"]
}
