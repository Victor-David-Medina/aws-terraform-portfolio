# ADR-004: Security-First CI/CD Pipeline

**Status:** Accepted
**Date:** 2026-01-25

## Context

Infrastructure code that passes `terraform validate` can still have serious security issues: overly permissive security groups, unencrypted storage, public S3 buckets, or hardcoded secrets. These problems are cheapest to catch before they reach AWS.

We need a CI/CD pipeline that:
- Runs on every push and pull request to main
- Catches security misconfigurations before they're deployed
- Validates Terraform syntax and formatting across all phases
- Doesn't require AWS credentials in GitHub (no IAM keys in CI)
- Demonstrates shift-left security thinking to hiring managers

## Decision

We implemented a **GitHub Actions workflow** with a 4-stage pipeline:

| Stage | Tool | Purpose | Failure behavior |
|-------|------|---------|-----------------|
| 1. Format | `terraform fmt -check -recursive` | Enforces consistent code style | Hard fail — blocks merge |
| 2. Security | `tfsec` (Aqua Security) | Static analysis for AWS misconfigurations | Soft fail — warns but doesn't block |
| 3. Init | `terraform init -backend=false` | Validates provider configuration | Hard fail — blocks merge |
| 4. Validate | `terraform validate` | Checks HCL syntax and resource arguments | Hard fail — blocks merge |

Key design choices:
- **tfsec runs with `soft_fail: true`** — security findings are visible in PR checks but don't block merges. This is intentional: some tfsec findings (like "no encryption on a demo S3 bucket") are accepted risks in a portfolio context. Hard-failing would require suppressing every finding, which teaches the wrong habit.
- **`-backend=false` on init** — the pipeline doesn't need AWS credentials because it never touches real state. This avoids storing IAM access keys in GitHub Secrets, which is itself a security decision.
- **Recursive format check** — catches formatting drift in all phases (01 through 05), not just the capstone.

## Alternatives Considered

- **Checkov (Bridgecrew)** — Another popular IaC scanner with broader policy support (CIS benchmarks, SOC2 controls). More features than tfsec but heavier setup and slower execution. Rejected for simplicity — tfsec covers the most common AWS misconfigurations and runs in seconds. Checkov would be the production upgrade.

- **terraform plan in CI** — Running `plan` would catch more errors (like invalid AMI IDs or subnet references) but requires AWS credentials in GitHub. Rejected because storing IAM keys in CI introduces the exact security risk we're trying to prevent. A future enhancement would use OIDC federation to assume a read-only role — no long-lived keys.

- **Pre-commit hooks (local only)** — Run tfsec and fmt locally before commits reach GitHub. Useful but unenforceable — any developer can skip hooks with `--no-verify`. Rejected as the sole mechanism because it can't guarantee compliance. Would be a good complement to CI, not a replacement.

- **AWS CodePipeline + CodeBuild** — Native AWS CI/CD that integrates with IAM roles natively (no keys in GitHub). More complex to set up, harder to showcase in a portfolio (recruiters look at GitHub Actions, not CodePipeline configs). Rejected because GitHub Actions is the industry standard for open-source Terraform projects.

- **No CI/CD** — Just run `terraform plan` and `apply` locally. Rejected because it provides zero visibility into code quality for reviewers, demonstrates no DevOps practices, and means every contributor must have local tooling configured identically.

## Consequences

**Positive:**
- Every PR gets automated security review — misconfigurations are visible before merge
- Zero AWS credentials in CI — eliminates a major attack surface
- Formatting enforcement prevents style drift across 5 phases and 20+ .tf files
- GitHub Actions badge in README provides immediate credibility signal to recruiters
- Pipeline runs in ~30 seconds — fast enough that developers won't skip it

**Negative:**
- `soft_fail` on tfsec means security findings can be merged — this is a risk acceptance, not a fix
- No `terraform plan` in CI means some errors (bad AMI IDs, missing resources) only surface during manual apply
- tfsec has false positives (e.g., flagging demo resources that intentionally lack encryption)
- Pipeline doesn't test destroy/cleanup — resource leaks won't be caught

**Operational:**
- If the format check fails: run `terraform fmt -recursive` locally and push the fix
- If tfsec finds a real issue: either fix it or add a `#tfsec:ignore:RULE_ID` comment with a rationale (never silently suppress)
- If validate fails: check for syntax errors, missing variables, or provider version mismatches
- To add `terraform plan`: configure OIDC federation between GitHub Actions and AWS IAM, assume a read-only role, run plan against the capstone directory

## Cost Impact

| Component | Monthly Cost |
|-----------|-------------|
| GitHub Actions (public repo) | $0 (free for public repos) |
| tfsec | $0 (open source) |
| Terraform CLI | $0 (open source) |
| **Total CI/CD** | **$0/mo** |

**Production upgrade costs:**
- GitHub Actions (private repo): Free tier includes 2,000 min/mo, then $0.008/min
- Checkov Pro: ~$0 (open source) or Bridgecrew platform for policy-as-code dashboards
- OIDC federation for plan: $0 (IAM configuration only)
