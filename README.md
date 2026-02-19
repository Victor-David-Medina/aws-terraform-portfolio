# Terraform Portfolio — VDM Cloud Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-1.10+-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-VPC%20%7C%20EC2%20%7C%20S3-FF9900?logo=amazon-aws)
![Terraform CI](https://github.com/Victor-David-Medina/aws-terraform-portfolio/actions/workflows/terraform.yml/badge.svg)
![Security](https://img.shields.io/badge/Security-tfsec%20scanned-blue)

Production-grade AWS infrastructure built with Terraform, featuring multi-AZ VPC architecture, Auto Scaling, GuardDuty security monitoring, and comprehensive operational documentation.

---

## About Me

Operations engineer with 8+ years leading enterprise system deployments, now building cloud infrastructure with Terraform and AWS. My background in logistics operations (USMC), SaaS platform rollouts (ezCater), and healthcare compliance (Amwell) gives me a strong foundation in reliability, process documentation, and incident response — the same skills that drive effective cloud operations.

---

## Start Here (If You Have 5 Minutes)

1. **Architecture diagram** — see below for the full VPC topology
2. **[Capstone project](./05-capstone/)** — production VPC with all the patterns
3. **[Architecture Decision Records](./05-capstone/docs/adr/README.md)** — the _why_ behind every choice
4. **[Operational Runbook](./05-capstone/docs/RUNBOOK.md)** — 7-scenario 3 AM troubleshooting guide

This path shows **how I think about Day-2 operations**, not just how I write Terraform.

---

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

---

## What Makes This Different

| Feature | What It Proves |
|---------|---------------|
| 5 Architecture Decision Records | Every design choice documented with tradeoffs and alternatives |
| 7-Scenario Operational Runbook | Copy-paste CLI commands for 3 AM troubleshooting |
| Incident Response Procedure | Detect → Triage → Mitigate → Resolve → Document lifecycle |
| Security-First CI/CD | tfsec on every push, zero AWS credentials in CI |
| Security Decisions Document | Every firewall rule has a documented WHY |
| Dev vs Prod Cost Comparison | FinOps thinking on every resource |
| 50+ Progressive Commits | Real iteration, not a code dump |

---

## Project Structure

| Folder | Description | Key Concepts |
|--------|-------------|-------------|
| `01-s3-bucket/` | S3 state backend | Remote state, versioning |
| `02-vpc/` | Basic VPC | Subnets, route tables, IGW |
| `03-modules/` | Reusable modules | Module design, variables, DRY |
| `04-advanced-hcl/` | Advanced patterns | Loops, conditionals, validation |
| `05-capstone/` | **Production VPC** | Multi-AZ, ASG, GuardDuty, CI/CD, full ops docs |

Each phase builds on the previous one, progressing from basic resources to a production-style, multi-AZ infrastructure with monitoring, security, and operational documentation.

---

## Estimated Monthly Cost

| Resource | Dev ($/mo) | Prod ($/mo) | Notes |
|----------|-----------|------------|-------|
| EC2 t3.micro ×2 | ~$15 | ~$46 (×6 max) | Free Tier: 750 hrs/mo for first 12 months |
| NAT Gateway | ~$32 | ~$64 (HA, 2 AZs) | Biggest single cost; see ADR-003 |
| ALB | — | ~$16 | Not deployed in dev; prod needs it |
| S3 (state bucket) | <$1 | <$1 | Versioning + encryption |
| GuardDuty | ~$5 | ~$5 | Per-account pricing |
| CloudWatch | <$1 | ~$3 | Alarms + dashboard |
| **Total** | **~$53** | **~$135** | |

---

## Documentation

All documentation lives in the capstone project:

- [Architecture Decision Records](./05-capstone/docs/adr/README.md) — 5 ADRs covering VPC, ASG, NAT, CI/CD, and remote state
- [Operational Runbook](./05-capstone/docs/RUNBOOK.md) — Deployment + 5 incident procedures
- [Incident Response](./05-capstone/docs/INCIDENT-RESPONSE.md) — Severity definitions, lifecycle, communication templates
- [Security Decisions](./05-capstone/docs/SECURITY-DECISIONS.md) — Why every SG rule exists
- [Backend Setup Guide](./05-capstone/backend-setup/README.md) — S3 remote state bootstrap runbook

---

## Technologies

| Category | Tools |
|----------|-------|
| IaC | Terraform 1.10+, HCL |
| Cloud | AWS (VPC, EC2, ASG, S3, GuardDuty, CloudWatch, Budgets) |
| CI/CD | GitHub Actions |
| Security | tfsec, least-privilege security groups, SSM Session Manager |
| Documentation | ADRs, operational runbooks, incident response, cost tables |

---

## Certifications

- **AWS Cloud Practitioner (CLF-C02)** — In Progress

---

## Contact

- **LinkedIn:** [linkedin.com/in/victor-david-medina](https://linkedin.com/in/victor-david-medina)
- **Email:** [v.davidmedina@gmail.com](mailto:v.davidmedina@gmail.com)
- **Location:** Boston, MA
