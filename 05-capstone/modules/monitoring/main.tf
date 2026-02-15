# modules/monitoring/main.tf
# CloudWatch alarms for infrastructure health and scaling visibility
#
# These alarms complement the ASG target tracking policy by providing
# operational visibility. Target tracking handles the actual scaling;
# these alarms notify the operations team when thresholds are breached.

# -----------------------------------------------------------------------------
# HIGH CPU ALARM
# Triggers when average CPU exceeds threshold for 2 consecutive periods
# Indicates the ASG is scaling up - useful for capacity planning reviews
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-high"
  alarm_description   = "CPU utilization exceeded ${var.cpu_high_threshold}% - ASG scaling up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_high_threshold

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cpu-high"
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# LOW CPU ALARM
# Triggers when average CPU drops below threshold for 3 consecutive periods
# Indicates potential over-provisioning - review for cost optimization
# Using 3 periods (15 min) avoids false alarms during brief traffic dips
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-low"
  alarm_description   = "CPU utilization below ${var.cpu_low_threshold}% - review for cost optimization"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_low_threshold

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cpu-low"
    Environment = var.environment
  }
}
