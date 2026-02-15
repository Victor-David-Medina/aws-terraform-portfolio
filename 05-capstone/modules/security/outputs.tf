# modules/security/outputs.tf

output "web_sg_id" {
  description = "Web security group ID"
  value       = aws_security_group.web.id
}

output "db_sg_id" {
  description = "Database security group ID"
  value       = aws_security_group.db.id
}