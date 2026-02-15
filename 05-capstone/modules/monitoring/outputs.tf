# modules/monitoring/outputs.tf

output "cpu_high_alarm_arn" {
  description = "ARN of the high CPU alarm - can be used for SNS notification wiring"
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "cpu_low_alarm_arn" {
  description = "ARN of the low CPU alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_low.arn
}
