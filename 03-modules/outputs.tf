# outputs.tf (ROOT folder)
output "dev_vpc_id" {
  value = module.vpc_dev.vpc_id
}

output "prod_vpc_id" {
  value = module.vpc_prod.vpc_id
}