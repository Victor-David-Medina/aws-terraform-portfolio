# =============================================================================
# 05-capstone/outputs.tf
# Root module outputs - exposes key resource IDs for reference and debugging
# =============================================================================

# --- Networking ---
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = module.vpc.nat_gateway_ip
}

# --- Security ---
output "web_security_group" {
  description = "Web security group ID"
  value       = module.security.web_sg_id
}

output "db_security_group" {
  description = "DB security group ID"
  value       = module.security.db_sg_id
}

# --- Compute ---
output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.compute.asg_name
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = module.compute.launch_template_id
}

# --- Security Monitoring ---
output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = module.security_monitoring.detector_id
}

# --- Cost ---
output "budget_name" {
  description = "AWS Budget name"
  value       = module.cost.budget_name
}
# --- Monitoring ---
output "cpu_high_alarm_arn" {
  description = "High CPU CloudWatch alarm ARN"
  value       = module.monitoring.cpu_high_alarm_arn
}

output "cpu_low_alarm_arn" {
  description = "Low CPU CloudWatch alarm ARN"
  value       = module.monitoring.cpu_low_alarm_arn
}