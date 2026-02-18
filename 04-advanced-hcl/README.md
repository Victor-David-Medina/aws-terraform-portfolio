# Phase 04: Advanced HCL — Workspaces and Dynamic Configuration

> **Problem:** Managing dev, staging, and prod with separate `.tf` files doesn't scale. You need one config that adapts to the active workspace.

## What This Deploys

| Resource | Purpose | Monthly Cost |
|----------|---------|-------------|
| `aws_vpc` | Environment-specific VPC — CIDR changes per workspace | $0 |

Workspace → CIDR mapping:

| Workspace | CIDR Block | Use Case |
|-----------|-----------|----------|
| `default` | 10.0.0.0/16 | Local testing |
| `dev` | 10.1.0.0/16 | Development |
| `prod` | 10.2.0.0/16 | Production |

## Architecture

```
terraform workspace select dev
            ↓
    ┌───────────────────┐
    │  workspace_config  │
    │  (local map)       │
    │                   │
    │  "dev"  → 10.1.0.0/16  │
    │  "prod" → 10.2.0.0/16  │
    └───────────────────┘
            ↓
    lookup(local.workspace_config, terraform.workspace)
            ↓
    [VPC with workspace-specific CIDR + tags]
```

## Key Decisions

- **`terraform.workspace` as the environment switch** — no extra variables or `.tfvars` files needed. The workspace name IS the environment
- **`lookup()` with map** — cleaner than nested conditionals. Adding a staging environment means adding one line to the map, not rewriting logic
- **Tags include workspace name** — every resource self-documents which environment it belongs to. Critical for cost allocation and incident response
- **Separate state per workspace** — Terraform isolates state automatically. Dev changes can never accidentally affect prod

## What I Learned

1. **Workspaces vs. modules — different problems** — Phase 03 used modules to create multiple VPCs in one apply. Workspaces create one VPC per environment with isolated state. The real answer in production is often both: workspaces for environment separation, modules for code reuse
2. **`lookup()` is a safer alternative to conditionals** — `var == "dev" ? x : y` breaks at 3 environments. A map with `lookup()` scales to any number of environments and fails explicitly if the key doesn't exist
3. **State isolation prevents catastrophic mistakes** — when dev and prod share state, one bad `terraform destroy` can wipe production. Workspaces keep state files separate by default

## Deploy

```bash
cd 04-advanced-hcl

# Initialize
terraform init

# Create and switch to dev workspace
terraform workspace new dev
terraform workspace select dev

# Preview — shows VPC with 10.1.0.0/16
terraform plan

# Deploy dev environment
terraform apply

# Switch to prod and deploy separately
terraform workspace new prod
terraform workspace select prod
terraform plan    # Shows VPC with 10.2.0.0/16
terraform apply

# List all workspaces
terraform workspace list

# Verify outputs
terraform output workspace_name
terraform output vpc_cidr
```

## Cleanup

```bash
# Destroy prod first
terraform workspace select prod
terraform destroy

# Then dev
terraform workspace select dev
terraform destroy

# Return to default
terraform workspace select default
```

> **Note:** Each workspace has its own state. You must `select` into a workspace before you can `destroy` its resources. Forgetting this is how people accidentally leave orphaned infrastructure running.

---

📂 **Previous:** [03-modules](../03-modules) | **Next:** [05-capstone](../05-capstone) — Everything comes together
