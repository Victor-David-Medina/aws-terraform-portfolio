# =============================================================================
# modules/vpc/outputs.tf
# VDM Cloud Infrastructure - VPC Module Outputs
#
# Outputs enable cross-module references and stack dependencies
# All outputs include descriptions explaining their use cases
# =============================================================================

# -----------------------------------------------------------------------------
# VPC OUTPUTS
# Referenced by security groups, EC2 instances, RDS, and other services
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID - required by security groups, subnets, and any resource deployed within this VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block - used in security group rules to allow internal traffic"
  value       = aws_vpc.main.cidr_block
}

# -----------------------------------------------------------------------------
# SUBNET OUTPUTS
# Used by Auto Scaling Groups, Load Balancers, RDS subnet groups
# -----------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "List of public subnet IDs - use for load balancers, bastion hosts, and NAT gateways"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs - use for application servers, databases, and internal services"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks - use in security group rules for public tier access"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks - use in security group rules for private tier access"
  value       = aws_subnet.private[*].cidr_block
}

# -----------------------------------------------------------------------------
# GATEWAY OUTPUTS
# NAT Gateway IP useful for whitelisting outbound traffic
# -----------------------------------------------------------------------------

output "nat_gateway_id" {
  description = "NAT Gateway ID - reference for route table modifications or monitoring"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP - whitelist this IP for private subnet outbound traffic to external services"
  value       = aws_eip.nat.public_ip
}

output "internet_gateway_id" {
  description = "Internet Gateway ID - reference for public route table modifications"
  value       = aws_internet_gateway.main.id
}

# -----------------------------------------------------------------------------
# ROUTE TABLE OUTPUTS
# Useful for adding custom routes from other modules
# -----------------------------------------------------------------------------

output "public_route_table_id" {
  description = "Public route table ID - use to add custom routes for public subnet traffic"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Private route table ID - use to add custom routes for private subnet traffic"
  value       = aws_route_table.private.id
}
