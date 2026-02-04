# =============================================================================
# modules/vpc/main.tf
# VDM Cloud Infrastructure - VPC Module
# 
# Creates a production-ready VPC with public/private subnet architecture
# Multi-AZ deployment for high availability
# =============================================================================

# -----------------------------------------------------------------------------
# VPC FOUNDATION
# Using /16 CIDR to allow growth - provides 65,536 IP addresses
# DNS hostnames enabled for EC2 instance DNS resolution
# -----------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true # Required for EC2 instances to receive DNS hostnames
  enable_dns_support   = true # Required for Route 53 private hosted zones

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Component   = "networking"
  })
}

# -----------------------------------------------------------------------------
# INTERNET GATEWAY
# Single IGW per VPC - enables internet connectivity for public subnets
# Must be created before public route table routes
# -----------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Component   = "networking"
  })
}

# -----------------------------------------------------------------------------
# PUBLIC SUBNETS
# Hosts: Load balancers, bastion hosts, NAT gateways
# map_public_ip_on_launch = true for direct internet access
# Spread across AZs for high availability
# -----------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true # Instances get public IPs automatically

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-public-${var.availability_zones[count.index]}"
    Environment = var.environment
    Component   = "networking"
    Tier        = "public"
  })
}

# -----------------------------------------------------------------------------
# PRIVATE SUBNETS
# Hosts: Application servers, databases, internal services
# No public IPs - internet access via NAT Gateway only
# Provides security isolation for sensitive workloads
# -----------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  # No map_public_ip_on_launch - private subnets should not have public IPs

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-private-${var.availability_zones[count.index]}"
    Environment = var.environment
    Component   = "networking"
    Tier        = "private"
  })
}

# -----------------------------------------------------------------------------
# NAT GATEWAY + ELASTIC IP
# Enables private subnet instances to reach internet (for updates, API calls)
# Single NAT in first public subnet - production would use one per AZ
# EIP required for static outbound IP address
# -----------------------------------------------------------------------------

resource "aws_eip" "nat" {
  domain = "vpc" # Required for VPC NAT Gateway association

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-nat-eip"
    Environment = var.environment
    Component   = "networking"
  })

  # EIP may require IGW to exist first
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Place in first public subnet

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-nat"
    Environment = var.environment
    Component   = "networking"
  })

  # NAT Gateway requires IGW to be attached to VPC first
  depends_on = [aws_internet_gateway.main]
}

# -----------------------------------------------------------------------------
# ROUTE TABLES
# Public RT: Routes 0.0.0.0/0 to Internet Gateway (direct internet)
# Private RT: Routes 0.0.0.0/0 to NAT Gateway (outbound only)
# This separation enforces network security boundaries
# -----------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                  # All internet-bound traffic
    gateway_id = aws_internet_gateway.main.id # Goes directly to IGW
  }

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Component   = "networking"
    Tier        = "public"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"             # All internet-bound traffic
    nat_gateway_id = aws_nat_gateway.main.id # Routes through NAT (outbound only)
  }

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-private-rt"
    Environment = var.environment
    Component   = "networking"
    Tier        = "private"
  })
}

# -----------------------------------------------------------------------------
# ROUTE TABLE ASSOCIATIONS
# Links subnets to their respective route tables
# Without association, subnets use VPC's main route table (not recommended)
# -----------------------------------------------------------------------------

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
