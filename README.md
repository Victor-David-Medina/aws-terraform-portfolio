# Terraform Portfolio — VDM Cloud Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-1.10+-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-VPC%20%7C%20EC2%20%7C%20ASG%20%7C%20S3-FF9900?logo=amazonwebservices)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?logo=githubactions)
![Security](https://img.shields.io/badge/Security-tfsec_scanned-blue)
![Terraform CI](https://github.com/Victor-David-Medina/aws-terraform-portfolio/actions/workflows/terraform.yml/badge.svg)

> Production-grade AWS infrastructure built with Terraform — multi-AZ VPC, Auto Scaling, GuardDuty threat detection, and full Day-2 operational documentation including runbooks, incident response procedures, and architecture decision records.

---

## About Me

Operations professional with 8+ years leading enterprise system deployments, now building cloud infrastructure with Terraform and AWS. My background in military logistics (USMC), SaaS platform operations (ezCater), and healthcare compliance (Amwell) gives me a strong foundation in reliability, process discipline, incident response, and documentation — the same principles that drive effective cloud operations and DevOps.

**What I bring to a Cloud/DevOps team:** The ability to think past `terraform apply` — designing for operability, documenting decisions for the next on-call engineer, and building infrastructure that's maintainable at 3 AM.

---

## Start Here

| Time | What to Read | What It Shows |
|------|-------------|---------------|
| 30 sec | [Architecture diagram](#architecture) below | Multi-AZ VPC topology at a glance |
| 2 min | [`05-capstone/`](./05-capstone/) | Production VPC with all patterns composed |
| 3 min | [Architecture Decision Records](./05-capstone/docs/adr/README.md) | The _why_ behind every design choice |
| 5 min | [Operational Runbook](./05-capstone/docs/RUNBOOK.md) | 5 incident procedures — copy-paste CLI commands |

> This portfolio demonstrates **how I think about Day-2 operations** — not just how I write Terraform.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                               AWS REGION                                │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                        VPC (10.0.0.0/16)                        │    │
│  │                                                                 │    │
│  │    ┌─────────────┐              ┌─────────────┐                 │    │
│  │    │  Public     │              │  Public     │                 │    │
│  │    │  Subnet     │              │  Subnet     │                 │    │
│  │    │  AZ-a       │              │  AZ-b       │                 │    │
│  │    │ 10.0.1.0/24 │              │ 10.0.2.0/24 │                 │    │
│  │    │             │              │             │    ┌────────┐   │    │
│  │    │ ┌─────────┐ │              │             │    │  IGW   │   │    │
│  │    │ │   NAT   │ │              │             │    │        │── ┼─── ┼──► Internet
│  │    │ │ Gateway │ │              │             │    └────────┘   │    │
│  │    │ └────┬────┘ │              │             │                 │    │
│  │    └──────┼──────┘              └─────────────┘                 │    │
│  │           │                                                     │    │
│  │    ┌──────▼──────┐              ┌─────────────┐                 │    │
│  │    │  Private    │              │  Private    │                 │    │
│  │    │  Subnet     │              │  Subnet     │                 │    │
│  │    │  AZ-a       │              │  AZ-b       │                 │    │
│  │    │ 10.0.10.0/24│              │10.0.20.0/24 │                 │    │
│  │    │             │              │             │                 │    │
│  │    │ ┌─────────┐ │   ◄──ASG──►  │ ┌─────────┐ │                 │    │
│  │    │ │   EC2   │ │              │ │   EC2   │ │                 │    │
│  │    │ │ (min:2) │ │              │ │ (max:6) │ │                 │    │
│  │    │ └─────────┘ │              │ └─────────┘ │                 │    │
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

## What This Project Demonstrates

| Competency | Implementation | Where to Look |
|-----------|---------------|---------------|
| **Infrastructure as Code** | Multi-AZ VPC with 6 Terraform modules, DRY patterns | [`05-capstone/`](./05-capstone/) |
| **CI/CD Pipelines** | 4-stage GitHub Actions: fmt → tfsec → init → validate | [`.github/workflows/`](./.github/workflows/terraform.yml) |
| **Monitoring & Alerting** | CloudWatch CPU alarms, GuardDuty threat detection | [`modules/monitoring/`](./05-capstone/modules/monitoring/) |
| **Network Security** | Least-privilege SGs, SG chaining, SSM-only access (no SSH) | [`SECURITY-DECISIONS.md`](./05-capstone/docs/SECURITY-DECISIONS.md) |
| **Incident Response** | 5 runbook procedures, severity matrix, comms templates | [`RUNBOOK.md`](./05-capstone/docs/RUNBOOK.md) |
| **Architecture Decisions** | 5 ADRs with tradeoffs, alternatives, and cost impact | [`docs/adr/`](./05-capstone/docs/adr/) |
| **Cost Optimization** | Budget alerts, single NAT tradeoff, FinOps-aware design | [`ADR-003`](./05-capstone/docs/adr/ADR-003-single-nat-gateway.md) |
| **State Management** | S3 backend with `use_lockfile`, bootstrap pattern | [`backend-setup/`](./05-capstone/backend-setup/) |

---

## CI/CD Pipeline

Every push triggers a security-first validation pipeline — zero AWS credentials required in CI.

```
  ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
  │   fmt    │────►│  tfsec   │────►│   init   │────►│ validate │
  │  check   │     │   scan   │     │ (no AWS) │     │  (HCL)   │
  └──────────┘     └──────────┘     └──────────┘     └──────────┘
   Formatting       Security         Provider         Syntax &
    standards        scanning         setup           references
```

See [ADR-004](./05-capstone/docs/adr/ADR-004-security-first-cicd.md) for the design rationale.

---

## Project Structure

Each phase builds on the previous one — from basic resources to production-grade infrastructure with monitoring, security, and operational documentation.

| Phase | Folder | What It Builds | Key Concepts |
|:-----:|--------|---------------|-------------|
| 1 | [`01-s3-bucket/`](./01-s3-bucket/) | S3 state bucket | Provider versioning, tagging, init/plan/apply lifecycle |
| 2 | [`02-vpc/`](./02-vpc/) | Basic VPC | Subnets, route tables, IGW, DNS settings |
| 3 | [`03-modules/`](./03-modules/) | Reusable modules | Module design, `cidrsubnet()`, S3 backend, DRY patterns |
| 4 | [`04-advanced-hcl/`](./04-advanced-hcl/) | Workspace config | Workspaces, `lookup()`, environment isolation |
| 5 | [`05-capstone/`](./05-capstone/) | **Production VPC** | Multi-AZ, ASG, GuardDuty, CI/CD, full operational docs |

---

## Estimated Monthly Cost

| Resource | Dev ($/mo) | Prod ($/mo) | Notes |
|----------|-----------|------------|-------|
| EC2 t3.micro ×2 | ~$15 | ~$46 (×6 max) | Free Tier: 750 hrs/mo for first 12 months |
| NAT Gateway | ~$32 | ~$64 (HA, 2 AZs) | Biggest single cost — see [ADR-003](./05-capstone/docs/adr/ADR-003-single-nat-gateway.md) |
| ALB | — | ~$16 | Not deployed in dev; prod needs it |
| S3 (state bucket) | <$1 | <$1 | Versioning + encryption |
| GuardDuty | ~$5 | ~$5 | Per-account pricing |
| CloudWatch | <$1 | ~$3 | Alarms + dashboard |
| **Total** | **~$53** | **~$135** | |

---

## Documentation

All operational documentation lives in the capstone project:

| Document | Purpose |
|----------|---------|
| [Architecture Decision Records](./05-capstone/docs/adr/README.md) | 5 ADRs covering VPC, ASG, NAT, CI/CD, and remote state |
| [Operational Runbook](./05-capstone/docs/RUNBOOK.md) | Deployment procedures + 5 incident playbooks |
| [Incident Response](./05-capstone/docs/INCIDENT-RESPONSE.md) | Severity matrix, lifecycle, communication templates |
| [Security Decisions](./05-capstone/docs/SECURITY-DECISIONS.md) | Why every security group rule exists |
| [Backend Setup](./05-capstone/backend-setup/README.md) | S3 remote state bootstrap guide |
| [Project Notes](./docs/PROJECT-NOTES.md) | Build retrospective and lessons learned |

---

## Technologies

| Category | Tools |
|----------|-------|
| Infrastructure as Code | Terraform 1.10+, HCL |
| Cloud Platform | AWS (VPC, EC2, ASG, S3, GuardDuty, CloudWatch, Budgets) |
| CI/CD | GitHub Actions (security-first pipeline) |
| Security | tfsec scanning, least-privilege SGs, SSM Session Manager |
| State Management | S3 backend with `use_lockfile`, encryption, versioning |
| Documentation | ADRs, operational runbooks, incident response, cost analysis |

---

## Certifications

**AWS Cloud Practitioner (CLF-C02)** — In Progress

---

## Contact

**Victor David Medina** — Boston, MA

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Victor_David_Medina-0A66C2?logo=linkedin&logoColor=white)](https://linkedin.com/in/victor-david-medina)
[![Email](https://img.shields.io/badge/Email-v.davidmedina%40gmail.com-EA4335?logo=gmail&logoColor=white)](mailto:v.davidmedina@gmail.com)
