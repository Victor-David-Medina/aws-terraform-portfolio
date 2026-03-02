# Phase 03: Modules — DRY Infrastructure with Reusable Components

> **Problem:** Copy-pasting VPC configs for every environment creates drift and maintenance nightmares. You need one module, multiple deployments.

## What This Deploys

| Resource | Purpose | Monthly Cost |
|----------|---------|-------------|
| `module "vpc_dev"` | Dev VPC (10.0.0.0/16) with public subnet | $0 |
| `module "vpc_prod"` | Prod VPC (10.1.0.0/16) with public subnet | $0 |
| S3 backend | Remote state with encryption and locking | $0 (Free Tier) |

## Architecture

```
┌───────────────────────────────────────────┐
│               main.tf (root)              │
│                                           │
│  module "vpc_dev"  ──→ ./modules/vpc      │
│    vpc_cidr     = "10.0.0.0/16"           │
│    environment  = "dev"                   │
│                                           │
│  module "vpc_prod" ──→ ./modules/vpc      │
│    vpc_cidr     = "10.1.0.0/16"           │
│    environment  = "prod"                  │
└───────────────────────────────────────────┘
                    ↓
          [S3 Remote State]
          encrypted, locked
```

## Key Decisions

- **Module pattern** — same VPC code deploys dev and prod with different CIDRs. Change the module once, both environments update
- **`cidrsubnet()` in the module** — calculates subnet CIDRs mathematically instead of hardcoding. `cidrsubnet("10.0.0.0/16", 8, 1)` = `10.0.1.0/24`
- **S3 backend with `use_lockfile`** — remote state prevents "it works on my machine" and locking prevents two engineers from running `apply` simultaneously
- **Environment tags from variables** — every resource knows if it's dev or prod. This drives IAM policies, cost reports, and incident triage

## What I Learned

1. **Modules are functions for infrastructure** — inputs (variables), processing (resources), outputs. The same mental model from programming applies. One VPC module, two calls, two completely isolated networks
2. **Remote state is non-negotiable for teams** — local `.tfstate` files work solo but break the moment a second person touches the project. S3 + locking is the standard
3. **`cidrsubnet()` eliminates CIDR math errors** — instead of manually calculating `10.0.1.0/24`, `10.0.2.0/24`, let Terraform do it. Fewer typos, consistent subnetting across environments

## File Structure

```
03-modules/
├── main.tf              # Root — calls vpc module twice (dev + prod)
├── outputs.tf           # Exposes module outputs
└── modules/
    └── vpc/
        └── main.tf      # Reusable VPC: vpc + public subnet + tags
```

## Deploy

```bash
cd 03-modules

# Initialize — downloads provider + configures S3 backend
terraform init

# Preview — shows dev AND prod VPC resources
terraform plan

# Deploy — creates both VPCs in one apply
terraform apply

# Verify both environments exist
terraform output
```

## Cleanup

```bash
terraform destroy
```

> **Note:** Remote state in S3 persists after destroy. The state file records that resources were removed, but the bucket and state file remain for audit history.

---

📂 **Previous:** [02-vpc](../02-vpc) | **Next:** [04-advanced-hcl](../04-advanced-hcl) — Workspaces and dynamic configuration
