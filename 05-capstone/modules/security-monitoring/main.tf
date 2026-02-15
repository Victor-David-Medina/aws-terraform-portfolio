# modules/security-monitoring/main.tf
# GuardDuty threat detection for continuous security monitoring
#
# GuardDuty analyzes VPC Flow Logs, CloudTrail events, and DNS logs
# to detect threats like compromised instances, reconnaissance, and
# unauthorized access. No agents required - fully managed by AWS.
#
# Cost: ~$4-5/month for a small environment (priced per event volume)

# -----------------------------------------------------------------------------
# GUARDDUTY DETECTOR
# Single enable creates the detector and begins monitoring immediately
# Finding types: Recon, Trojan, UnauthorizedAccess, Backdoor, etc.
# -----------------------------------------------------------------------------
resource "aws_guardduty_detector" "main" {
  enable = true

  # S3 protection monitors for suspicious bucket activity
  datasources {
    s3_logs {
      enable = true
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-guardduty"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
