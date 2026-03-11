# ADR-001: VPC Architecture Design



**Status:** Accepted | **Date:** 2026-01-20



## Context



We need a VPC design that provides:

- High availability across multiple AZs

- Network isolation between public and private resources

- Secure internet access for private resources

- Cost-effective for demonstration purposes



## Decision



Implement a multi-AZ VPC with:

- **CIDR:** 10.0.0.0/16 (65,536 IPs)

- **Public subnets:** 10.0.1.0/24, 10.0.2.0/24 (AZ-a, AZ-b)

- **Private subnets:** 10.0.10.0/24, 10.0.20.0/24 (AZ-a, AZ-b)

- **Single NAT Gateway** in public subnet (cost optimization)



## Consequences



**Positive:**

- Clear network segmentation (public vs private)

- Easy to extend to HA NAT in production

- Follows AWS Well-Architected Framework



**Trade-offs:**

- Single NAT Gateway is SPOF (acceptable for demo)

- Cross-AZ data transfer costs if NAT fails over



## Alternatives Considered



1. **NAT Instance** - Rejected: More operational overhead, less reliable

2. **VPC Endpoints** - Rejected: Doesn't cover all services needed

3. **Single-AZ** - Rejected: Not a production pattern



#
