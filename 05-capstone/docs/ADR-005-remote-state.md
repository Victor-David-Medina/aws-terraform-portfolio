# ADR-005: Remote State with S3 + DynamoDB Locking

**Status:** Accepted
**Date:** 2026-01-25

## Context

Terraform tracks every resource it manages in a state file (`terraform.tfstate`). By default, this file lives on the local filesystem. This works for solo development but creates serious problems at team scale:

- **No collaboration:** Two engineers can't safely run `terraform apply` at the same time — concurrent writes corrupt state
- **No audit trail:** Local state has no versioning — if you delete it or corrupt it, you lose track of what Terraform manages
- **No disaster recovery:** Laptop dies, state is gone, Terraform thinks your infrastructure doesn't exist
- **Secrets in plain text:** State files contain resource attributes including passwords, endpoints, and ARNs — a local file on a developer laptop is an unacceptable security risk

The capstone project needs remote state to demonstrate team-ready infrastructure practices.

## Decision

We use **S3 for state storage** with the following configuration:

| Component | Configuration | Purpose |
|-----------|--------------|---------|
| S3 bucket | `vdm-terraform-state-{random_hex}` | State file storage |
| Versioning | Enabled | Rollback to previous state versions |
| Public access | Blocked (all 4 settings) | Prevent accidental exposure |
| Locking | `use_lockfile = true` (.terraform.lock.hcl) | Prevent concurrent modifications |
| Encryption | S3 default encryption (SSE-S3) | Protect secrets in state at rest |

The backend configuration in the capstone:
```hcl
terraform {
  backend "s3" {
    bucket       = "vdm-terraform-state-XXXXX"
    key          = "capstone/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
```

A separate `backend-setup/` directory contains the Terraform code that creates the S3 bucket itself — solving the chicken-and-egg problem of "how do you create the bucket that stores your state."

## Alternatives Considered

- **Local state only** — Zero setup, zero cost, zero collaboration safety. Rejected because it demonstrates solo habits, not team practices. A hiring manager reviewing a portfolio project with local-only state would question whether the candidate understands team workflows. This is the single most common gap in junior cloud engineer portfolios.

- **S3 + DynamoDB locking (traditional pattern)** — The pre-2024 standard: DynamoDB table provides a lock record that prevents concurrent `terraform apply`. More robust than file-based locking for high-concurrency teams. Rejected for this project because Terraform 1.10+ supports `use_lockfile` which uses S3 conditional writes instead of DynamoDB, eliminating the ~$1/mo DynamoDB cost and the operational burden of maintaining the lock table. DynamoDB locking is the right choice for teams on older Terraform versions or with high-concurrency requirements.

- **Terraform Cloud (HCP)** — Hosted state management with built-in locking, run history, policy enforcement, and team access controls. Free tier supports up to 500 managed resources. Rejected because it hides the state management mechanics behind a SaaS interface — a portfolio project should show that you understand S3 backends, not that you can click through a hosted UI. Terraform Cloud would be appropriate for production teams.

- **GitLab/GitHub-managed state** — Store state in the VCS platform. Supported by GitLab CI natively. Rejected because it couples state to a specific CI platform, is not supported by GitHub Actions natively, and doesn't demonstrate AWS-native patterns.

- **Consul backend** — HashiCorp's service mesh tool also supports Terraform state storage with built-in locking. Rejected as overkill — Consul is a full service mesh. Using it solely for Terraform state is like buying a truck to carry a laptop.

## Consequences

**Positive:**
- State is versioned — S3 versioning allows rollback to any previous state if a bad apply corrupts resources
- State is encrypted at rest — SSE-S3 protects resource attributes, endpoints, and any secrets in state
- Public access is blocked at the bucket level — four separate settings prevent accidental exposure
- `use_lockfile` prevents concurrent applies — no DynamoDB table to manage
- Separate `backend-setup/` directory demonstrates understanding of the bootstrap problem

**Negative:**
- `use_lockfile` is newer (Terraform 1.10+) and some teams may not be familiar with it yet
- S3 conditional writes have a small race window under extreme concurrency — DynamoDB is more robust for large teams
- Backend configuration cannot use variables — bucket name must be hardcoded or passed via `-backend-config` flags
- If the S3 bucket is accidentally deleted, all state is lost (versioning + bucket policy mitigate this)
- No DynamoDB table means no lock metadata (who holds the lock, when it was acquired)

**Operational:**
- **State lock error:** If `terraform apply` fails mid-run and the lock isn't released, delete the `.terraform.lock.hcl` file from the S3 key path. In the DynamoDB pattern, you'd run `terraform force-unlock LOCK_ID`.
- **State corruption:** Enable S3 versioning (already configured). Restore the previous state version from S3 console → Versions tab.
- **Lost state:** If the state file is deleted, Terraform will try to recreate all resources. Run `terraform import` for each existing resource to rebuild state without destroying infrastructure.
- **Backend migration:** To move from local to remote state, add the backend block and run `terraform init -migrate-state`. Terraform will copy local state to S3.

## Cost Impact

| Component | Monthly Cost |
|-----------|-------------|
| S3 bucket (state storage) | ~$0.02 (state files are tiny, <1MB) |
| S3 versioning | ~$0.01 (minimal version history) |
| S3 PUT/GET requests | ~$0.01 (a few hundred per month) |
| DynamoDB (not used) | $0 (saved by using use_lockfile) |
| **Total state management** | **~$0.04/mo** |

**Production comparison:**
| Pattern | Monthly Cost | Best for |
|---------|-------------|----------|
| S3 + use_lockfile (this project) | ~$0.04 | Small teams, Terraform 1.10+ |
| S3 + DynamoDB | ~$1-2 | Larger teams, older Terraform |
| Terraform Cloud (free tier) | $0 | Teams wanting managed state |
| Terraform Cloud (paid) | $20/user/mo | Enterprise with policy needs |
