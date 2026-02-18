# Phase 01: S3 Bucket — Your First Terraform Resource

> **Problem:** You need a centralized, tagged storage bucket managed entirely through code — no ClickOps.

## What This Deploys

| Resource | Purpose | Monthly Cost |
|----------|---------|-------------|
| `aws_s3_bucket` | Object storage with environment tagging | $0 (Free Tier) |

## Architecture

```
Terraform CLI
    ↓
  [AWS Provider v5.x]
    ↓
  [S3 Bucket: vdm-dm-terraform]
    └── Tags: Environment=dev, Project=VDM-Cloud-Ops, ManagedBy=Terraform
```

## Key Decisions

- **Explicit provider version constraint** (`~> 5.0`) — prevents breaking changes from unexpected upgrades
- **Consistent tagging** — every resource gets `Environment`, `Project`, and `ManagedBy` from day one
- **Single region** (`us-east-1`) — cheapest region, keeps costs at $0 for learning

## What I Learned

1. **Terraform init/plan/apply lifecycle** — the mental model of "preview before you change anything" comes from the same discipline as double-entry accounting: verify before you commit
2. **Resource tagging as operational hygiene** — tags aren't decoration. In production, they drive cost allocation, access policies, and incident triage
3. **Provider versioning matters** — pinning `~> 5.0` means "any 5.x but never 6.0." One unversioned `terraform init` in prod can ruin your weekend

## Deploy

```bash
cd 01-s3-bucket

# Initialize — downloads the AWS provider
terraform init

# Preview — shows exactly what will be created
terraform plan

# Deploy — creates the S3 bucket
terraform apply

# Verify in AWS Console or CLI
aws s3 ls | grep vdm
```

## Cleanup

```bash
# Destroy — removes the bucket (must be empty)
terraform destroy
```

> **Note:** If the bucket contains objects, empty it first with `aws s3 rm s3://vdm-dm-terraform --recursive` before destroying.

---

📂 **Next:** [02-vpc](../02-vpc) — Build the network foundation
