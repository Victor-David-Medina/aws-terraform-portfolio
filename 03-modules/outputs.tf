# outputs.tf (ROOT folder)
output "dev_vpc_id" {
  description = "VPC ID for the dev environment"
  value       = module.vpc_dev.vpc_id
}

output "prod_vpc_id" {
  description = "VPC ID for the prod environment"
  value       = module.vpc_prod.vpc_id
}