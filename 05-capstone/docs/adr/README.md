# Architecture Decision Records

This directory contains the Architecture Decision Records (ADRs) for the capstone VPC project. ADRs capture the _why_ behind infrastructure choices — not just what we built, but which alternatives we evaluated, what tradeoffs we accepted, and what would change in production.

Each ADR follows a consistent template: Context → Decision → Alternatives Considered → Consequences → Cost Impact → Operational Notes.

## ADR Index

| ADR | Decision | Status |
|-----|----------|--------|
| [ADR-001](ADR-001-vpc-design.md) | Multi-AZ VPC with public/private subnets across 2 AZs | Accepted |
| [ADR-002](ADR-002-auto-scaling.md) | Target Tracking ASG at 70% CPU, min 2 / max 6 t3.micro | Accepted |
| [ADR-003](ADR-003-single-nat-gateway.md) | Single NAT Gateway — explicit dev-vs-prod cost tradeoff | Accepted |
| [ADR-004](ADR-004-security-first-cicd.md) | GitHub Actions pipeline: fmt → tfsec → init → validate (no AWS creds) | Accepted |
| [ADR-005](ADR-005-remote-state.md) | S3 backend with `use_lockfile` — no DynamoDB needed | Accepted |

> **If you only read one ADR, read [ADR-005](ADR-005-remote-state.md) (Remote State).** It explains the bootstrap problem, the `use_lockfile` choice over DynamoDB, and the separated `backend-setup/` pattern.

## How to Propose a New ADR

1. Copy the template structure from any existing ADR
2. Number sequentially (`ADR-006-topic-name.md`)
3. Set status to `Proposed`
4. Open a PR for team review
5. Update this index after the ADR is accepted
