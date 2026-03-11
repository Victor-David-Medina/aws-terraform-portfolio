# CLAUDE.md - Project Guidance for Claude Code

## Project Overview

AWS Terraform Portfolio by Victor David Medina - production-grade AWS infrastructure
built with Terraform, showcasing multi-AZ VPC architecture, Auto Scaling, GuardDuty,
and comprehensive operational documentation. This is a portfolio project that
demonstrates Day-2 operations thinking for cloud/SRE roles.

## Repository Structure

```
aws-terraform-portfolio/
├── 01-s3-bucket/          # Phase 1: S3 state backend basics
├── 02-vpc/                # Phase 2: Basic VPC fundamentals
├── 03-modules/            # Phase 3: Reusable module patterns
├── 04-advanced-hcl/       # Phase 4: Workspaces, loops, validation
├── 05-capstone/           # Phase 5: Production VPC stack (primary focus)
│   ├── modules/           # Terraform modules (vpc, compute, security, monitoring, cost)
│   ├── docs/              # ADRs, runbook, incident response, security decisions
│   └── backend-setup/     # S3 remote state bootstrap
├── backend-setup/         # Shared backend infrastructure
├── docs/                  # Project-level documentation
├── .bmad/                 # BMAD methodology (agents, skills, checklists)
└── .github/workflows/     # CI/CD pipeline
```

## Key Commands

```bash
# Format check
terraform fmt -check -recursive

# Validate capstone (primary project)
cd 05-capstone && terraform init -backend=false && terraform validate

# Validate all phases
for dir in 01-s3-bucket 02-vpc 03-modules 04-advanced-hcl 05-capstone; do
  echo "=== $dir ===" && cd "$dir" && terraform init -backend=false && terraform validate && cd ..
done

# Security scan
tfsec .

# Plan (requires AWS credentials)
cd 05-capstone && terraform plan
```

## Development Guidelines

### Terraform Conventions
- **Naming pattern**: `${project_name}-${var.environment}-${resource_type}`
- **Tagging**: Always use `merge(var.common_tags, { ... })` for consistent tagging
- **Variables**: Every variable must have a `description` and `type`
- **Validation**: Use `validation` blocks on variables that accept constrained values
- **Comments**: Document the "why" not the "what" - reference ADRs and security docs
- **Modules**: One concern per module, consistent file structure (main.tf, variables.tf, outputs.tf)

### Security Posture
- No SSH - use SSM Session Manager (zero-trust access)
- Security group chaining between tiers (web SG > db SG)
- Private subnets for all application workloads
- All security decisions documented in `05-capstone/docs/SECURITY-DECISIONS.md`
- Never commit `.tfvars` files (they may contain sensitive values)

### Documentation Standards
- ADRs follow: Context > Decision > Alternatives > Consequences > Cost
- Runbook entries follow: Symptoms > Severity > Diagnosis > Resolution > Verification
- Every infrastructure decision should reference an ADR when applicable

### CI/CD
- `terraform fmt -check -recursive` on every push
- `tfsec` security scanning on every push
- `terraform validate` on capstone module
- No AWS credentials in CI - validation only

## BMAD Methodology

This project uses the BMAD (BMad Agent-Driven) methodology for AI-assisted development.
See `.bmad/` for agent definitions, skills, and quality checklists that guide
infrastructure work on this portfolio.

### Active Agents
- **infra-architect**: Reviews architecture decisions and module design
- **security-reviewer**: Validates security posture and compliance
- **ops-engineer**: Focuses on operational readiness and runbook quality

### Active Skills
- **tf-module-review**: Terraform module quality and best practices review
- **security-audit**: Security group and network policy audit
- **cost-review**: FinOps and cost optimization review

## Important Notes

- Phases 01-04 are learning exercises; Phase 05 (capstone) is the production reference
- The S3 backend block in `05-capstone/main.tf` is intentionally commented out for portability
- Email addresses in `terraform.tfvars.example` are placeholders - real values go in `.tfvars` (gitignored)
- This is a portfolio project - some production features (ALB, multi-NAT) are documented but not deployed to control costs
