# Production VPC Infrastructure

Multi-AZ AWS VPC with Auto Scaling, security monitoring, and operational documentation.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              AWS REGION                                 │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    VPC (10.0.0.0/16)                            │    │
│  │                                                                 │    │
│  │    ┌─────────────┐              ┌─────────────┐                 │    │
│  │    │  Public      │              │  Public      │                 │    │
│  │    │  Subnet      │              │  Subnet      │                 │    │
│  │    │  AZ-a        │              │  AZ-b        │                 │    │
│  │    │ 10.0.1.0/24  │              │ 10.0.2.0/24  │                 │    │
│  │    │              │              │              │    ┌────────┐   │    │
│  │    │ ┌─────────┐  │              │              │    │  IGW   │   │    │
│  │    │ │   NAT   │  │              │              │    │        │── ┼─── ┼──► Internet
│  │    │ │ Gateway │  │              │              │    └────────┘   │    │
│  │    │ └────┬────┘  │              │              │                 │    │
│  │    └──────┼──────┘              └─────────────┘                 │    │
│  │           │                                                     │    │
│  │    ┌──────▼──────┐              ┌─────────────┐                 │    │
│  │    │  Private     │              │  Private     │                 │    │
│  │    │  Subnet      │              │  Subnet      │                 │    │
│  │    │  AZ-a        │              │  AZ-b        │                 │    │
│  │    │ 10.0.10.0/24 │              │10.0.20.0/24  │                 │    │
│  │    │              │              │              │                 │    │
│  │    │ ┌─────────┐  │   ◄──ASG──►  │ ┌─────────┐  │                 │    │
│  │    │ │   EC2   │  │              │ │   EC2   │  │                 │    │
│  │    │ │ (min:2) │  │              │ │ (max:6) │  │                 │    │
│  │    │ └─────────┘  │              │ └─────────┘  │                 │    │
│  │    └─────────────┘              └─────────────┘                 │    │
│  │                                                                 │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐               │
│  │  GuardDuty   │    │  CloudWatch  │    │  S3 Backend  │               │
│  │  (Threats)   │    │  (Metrics)   │    │ (TF State)   │               │
│  └──────────────┘    └──────────────┘    └──────────────┘               │
└─────────────────────────────────────────────────────────────────────────┘
```

## Architecture Decisions

Every infrastructure choice in this project is documented as an Architecture Decision Record (ADR). See the [full ADR index](docs/adr/README.md) for context, alternatives considered, and cost analysis.

| ADR | Decision | Why It Matters |
|-----|----------|---------------|
| [ADR-001](docs/adr/ADR-001-vpc-design.md) | Multi-AZ VPC with public/private subnets | Foundation for all compute and networking |
| [ADR-002](docs/adr/ADR-002-auto-scaling.md) | Target Tracking ASG at 70% CPU, 2–6 instances | Elastic capacity without manual intervention |
| [ADR-003](docs/adr/ADR-003-single-nat-gateway.md) | Single NAT Gateway (dev cost tradeoff) | Saves ~$32/mo; documents the HA upgrade path |
| [ADR-004](docs/adr/ADR-004-security-first-cicd.md) | GitHub Actions: fmt → tfsec → init → validate | Security scanning with zero AWS credentials in CI |
| [ADR-005](docs/adr/ADR-005-remote-state.md) | S3 backend with `use_lockfile` | Remote state without DynamoDB — see [bootstrap docs](backend-setup/README.md) |

## Problem Statement

Organizations need scalable, secure VPC infrastructure that can be version-controlled, reviewed, and deployed consistently. This project demonstrates production patterns for AWS networking with Terraform.

## Quick Start

```bash
git clone https://github.com/Victor-David-Medina/aws-terraform-portfolio.git
cd aws-terraform-portfolio/05-capstone

# 1. Bootstrap remote state (one-time setup)
cd backend-setup && terraform init && terraform apply
cd ..

# 2. Configure and deploy
cp terraform.tfvars.example terraform.tfvars
terraform init        # connects to S3 backend
terraform plan
terraform apply
```

> **First time?** See [backend-setup/README.md](backend-setup/README.md) for the full bootstrap walkthrough and the chicken-and-egg problem it solves.

## Estimated Monthly Cost

| Resource | Cost |
|----------|------|
| NAT Gateway | ~$32 |
| EC2 t3.micro ×2 | ~$15 |
| GuardDuty | ~$5 |
| S3 state bucket | <$1 |
| **Total** | **~$53/month** |

## Documentation

- [RUNBOOK.md](docs/RUNBOOK.md) — Deployment and troubleshooting
- [Architecture Decision Records](docs/adr/README.md) — All 5 ADRs with rationale and cost analysis
- [Backend Bootstrap](backend-setup/README.md) — Remote state setup guide
