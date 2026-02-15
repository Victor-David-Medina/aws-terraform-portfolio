# modules/cost/main.tf
# AWS Budget alert for cost tracking and governance
#
# Demonstrates FinOps awareness - a key differentiator for operations roles.
# Budget alerts notify before costs exceed thresholds, preventing surprises.
# This module creates a monthly budget with alerts at 80% and 100%.

# -----------------------------------------------------------------------------
# MONTHLY BUDGET
# Tracks actual spend against a configurable monthly limit
# Alerts at 80% (warning) and 100% (critical) of budget
# Notification emails are sent directly by AWS - no SNS topic required
# -----------------------------------------------------------------------------
resource "aws_budgets_budget" "monthly" {
  name         = "${var.project_name}-${var.environment}-monthly"
  budget_type  = "COST"
  limit_amount = var.budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # 80% threshold - early warning for cost review
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }

  # 100% threshold - budget exceeded, immediate action needed
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-budget"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
