output "vpc_id" {
  description = "ID of the VPC - used by downstream modules to place resources in this network"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet - used for internet-facing resources like load balancers"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet - used for application servers and databases"
  value       = aws_subnet.private.id
}