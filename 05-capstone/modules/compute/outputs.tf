# modules/compute/outputs.tf

output "asg_name" {
  description = "Auto Scaling Group name - used by monitoring module for alarm targeting"
  value       = aws_autoscaling_group.app.name
}

output "asg_id" {
  description = "Auto Scaling Group ID"
  value       = aws_autoscaling_group.app.id
}

output "launch_template_id" {
  description = "Launch template ID for reference"
  value       = aws_launch_template.app.id
}
