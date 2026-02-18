# Phase 02: VPC — Network Foundation from Scratch

> **Problem:** You need isolated public and private subnets with internet access — the network layer every production workload sits on.

## What This Deploys

| Resource | Purpose | Monthly Cost |
|----------|---------|-------------|
| `aws_vpc` | Isolated network (10.0.0.0/16 = 65K IPs) | $0 |
| `aws_subnet` (public) | 10.0.1.0/24 — internet-facing resources | $0 |
| `aws_subnet` (private) | 10.0.2.0/24 — backend resources, no direct internet | $0 |
| `aws_internet_gateway` | Routes public subnet traffic to the internet | $0 |
| `aws_route_table` | Directs 0.0.0.0/0 → IGW for public subnet | $0 |
| `aws_route_table_association` | Binds public subnet to the route table | $0 |

## Architecture

```
Internet
    ↓
  [IGW]
    ↓
┌─────────────────────────┐
│  Public Subnet           │
│  10.0.1.0/24            │
│  (auto-assign public IP) │
│  Route: 0.0.0.0/0 → IGW │
└─────────────────────────┘

┌─────────────────────────┐
│  Private Subnet          │
│  10.0.2.0/24            │
│  (no internet route)     │
│  Isolated by default     │
└─────────────────────────┘

Both inside VPC: 10.0.0.0/16
```

## Key Decisions

- **Variables for CIDR and project name** — no hardcoded values means this config works for any environment
- **DNS hostnames enabled** — required for services like RDS that need resolvable DNS names inside the VPC
- **Public IP auto-assign on public subnet only** — private subnet stays isolated by default. This is least privilege at the network layer
- **Single AZ** (`us-east-1a`) — acceptable for learning; the capstone expands this to multi-AZ

## What I Learned

1. **Subnets don't have internet access by default** — a subnet is "public" only because you attach a route table pointing 0.0.0.0/0 to an IGW. Without that route, it's just another private subnet. This distinction matters in every VPC design conversation
2. **Route table associations are explicit** — Terraform forces you to understand that subnets and routes are separate concerns. In the console, this gets hidden behind wizards
3. **Outputs expose infrastructure to other phases** — exporting `vpc_id`, `public_subnet_id`, and `private_subnet_id` is how modules communicate. Phase 03 builds on this pattern

## Deploy

```bash
cd 02-vpc

# Initialize
terraform init

# Preview — verify 6 resources will be created
terraform plan

# Deploy
terraform apply

# Verify
terraform output vpc_id
terraform output public_subnet_id
```

## Cleanup

```bash
# Destroy all 6 resources
terraform destroy
```

> **Note:** If you've launched EC2 instances into these subnets, terminate them first or `destroy` will fail on dependency errors.

---

📂 **Previous:** [01-s3-bucket](../01-s3-bucket) | **Next:** [03-modules](../03-modules) — Refactor into reusable modules
