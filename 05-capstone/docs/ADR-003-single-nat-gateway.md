# ADR-003: Single NAT Gateway (Dev vs Prod Tradeoff)

**Status:** Accepted
**Date:** 2026-01-20

## Context

Private subnets need outbound internet access for package updates, API calls, and CloudWatch agent communication. AWS provides two options for this: NAT Gateways (managed) and NAT Instances (self-managed). Within the NAT Gateway approach, the key architectural question is: how many?

The capstone has 2 private subnets across 2 AZs. Each needs a route to the internet for outbound traffic without exposing instances to inbound connections.

NAT Gateway pricing is $0.045/hour (~$32/month) per gateway plus $0.045/GB of data processed. This is the single most expensive resource in the project.

## Decision

We deploy a **single NAT Gateway in the first public subnet (us-east-1a)** with both private subnets routing through it.

| Configuration | Value |
|--------------|-------|
| NAT Gateway count | 1 |
| Placement | Public subnet, us-east-1a |
| Route | Both private subnets → single NAT GW |
| Elastic IP | 1 (required per NAT GW) |

This is an explicit cost-optimization decision for a dev/portfolio environment, not a production recommendation. The README and this ADR document what production would require.

## Alternatives Considered

- **NAT Gateway per AZ (HA pattern)** — One NAT GW in each public subnet. Each private subnet routes to its local-AZ NAT GW. This is the AWS-recommended production pattern because it eliminates the cross-AZ single point of failure. Rejected for this project because it doubles the NAT cost from ~$32/mo to ~$64/mo with no functional benefit for a portfolio demo. Documented as the production upgrade path.

- **NAT Instance (t3.nano)** — A self-managed EC2 instance with source/dest check disabled, acting as a NAT device. Costs ~$3/mo vs $32/mo for a managed gateway. Rejected because NAT Instances require patching, monitoring, and manual failover — operational burden that contradicts the "managed services" philosophy. Also, NAT Instances have bandwidth limits tied to instance type.

- **VPC Endpoints only (no NAT)** — Use Gateway Endpoints for S3/DynamoDB and Interface Endpoints for other services. Eliminates NAT entirely. Rejected because Interface Endpoints cost $0.01/hour each (~$7/mo per service) and we'd need multiple (CloudWatch, SSM, EC2 API). Total cost would exceed a single NAT GW. Also, not all services support VPC Endpoints.

- **No outbound internet (fully isolated)** — Lock private subnets to AWS-internal traffic only. Rejected because instances need to pull OS updates, the CloudWatch agent needs to push metrics, and SSM needs connectivity for Session Manager. Full isolation requires VPC Endpoints for every service, which is more expensive and complex.

## Consequences

**Positive:**
- Saves ~$32/mo compared to HA NAT (one gateway vs two)
- Simpler routing — one NAT GW, one Elastic IP, two route table entries
- Demonstrates awareness of cost vs availability tradeoffs (interviewers love this)
- Easy upgrade path: add a second NAT GW and update the us-east-1b route table

**Negative:**
- **Single point of failure** — if us-east-1a has an AZ outage, private subnet instances in us-east-1b lose internet access
- Cross-AZ data transfer from us-east-1b private subnet to us-east-1a NAT GW costs $0.01/GB
- During AZ failure: instances stay running but can't reach external APIs, pull updates, or push CloudWatch metrics
- This is the most common "gotcha" in AWS interviews — you will be asked about it

**Operational:**
- If private instances suddenly can't reach the internet, check NAT Gateway status in us-east-1a first. If the AZ is impaired, AWS will report it on the Service Health Dashboard.
- **Recovery:** If the NAT GW's AZ fails, you must manually create a new NAT GW in us-east-1b and update route tables. This takes 5-10 minutes and requires Terraform apply or manual console work.
- **Production upgrade:** Add a second NAT GW in us-east-1b, create a second route table for private-2 subnet, and point it to the new NAT GW. This is a ~15 minute Terraform change.

## Cost Impact

| Configuration | Monthly Cost | Availability |
|--------------|-------------|--------------|
| **Single NAT GW (this project)** | **~$32/mo** | **Single-AZ dependent** |
| HA NAT GW (production) | ~$64/mo | Multi-AZ resilient |
| NAT Instance (t3.nano) | ~$3/mo | Single instance, manual failover |
| VPC Endpoints only | ~$21-49/mo (3-7 endpoints) | Per-service, no single SPOF |

**Why we accept the risk:** This is a portfolio/dev environment with no real users. The $32/mo savings from avoiding a second NAT GW is significant for a learning project. The architectural awareness of documenting this tradeoff demonstrates more operational maturity than silently deploying HA NAT without acknowledging the cost.
