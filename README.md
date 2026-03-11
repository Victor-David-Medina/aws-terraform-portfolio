# Terraform Portfolio: VDM Cloud Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-1.10+-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-VPC%20%7C%20EC2%20%7C%20S3-FF9900?logo=amazon-aws)
![CI](https://github.com/Victor-David-Medina/aws-terraform-portfolio/actions/workflows/terraform.yml/badge.svg)
![Security](https://img.shields.io/badge/Security-tfsec%20scanned-blue)
![License](https://img.shields.io/badge/License-MIT-green)

Production-grade AWS infrastructure built with Terraform. Multi-AZ VPC architecture with Auto Scaling, GuardDuty security monitoring, and full operational documentation.

---

## About Me

Cloud Operations Engineer and USMC veteran with 8+ years leading enterprise system deployments. I'm the founder of [RelayLaunch](https://github.com/Victor-David-Medina), a veteran-owned digital infrastructure consultancy, and I'm transitioning my operations background into cloud infrastructure with Terraform and AWS.

Previously at ezCater, I led a 1,000+ user SaaS platform rollout that cut reconciliation time by roughly 90%. At Amwell, I managed healthcare compliance workflows. That mix of logistics operations (USMC), SaaS delivery, and healthcare compliance gave me a strong foundation in reliability, process documentation, and incident response - the same skills I apply to cloud operations today.

---

## If You Have 5 Minutes

1. **Architecture diagram** below for the full VPC topology
2. **[Capstone project](./05-capstone/)** for the production VPC with all patterns applied
3. **[Architecture Decision Records](./05-capstone/docs/adr/README.md)** for the reasoning behind every choice
4. **[Operational Runbook](./05-capstone/docs/RUNBOOK.md)** for a 7-scenario troubleshooting guide

The goal is to show how I think about Day-2 operations, not just how I write Terraform.

---

## Architecture

```
+---------------------------------------------------------------------------+
|                              AWS REGION                                    |
|  +-------------------------------------------------------------------+   |
|  |                    VPC (10.0.0.0/16)                               |   |
|  |                                                                    |   |
|  |    +-------------+              +-------------+                    |   |
|  |    |  Public      |              |  Public      |                    |   |
|  |    |  Subnet      |              |  Subnet      |                    |   |
|  |    |  AZ-a        |              |  AZ-b        |                    |   |
|  |    | 10.0.1.0/24  |              | 10.0.2.0/24  |                    |   |
|  |    |              |              |              |    +--------+      |   |
|  |    | +---------+  |              |              |    |  IGW   |      |   |
|  |    | |   NAT   |  |              |              |    |        |--+---+-->Internet
|  |    | | Gateway |  |              |              |    +--------+      |   |
|  |    | +----+----+  |              |              |                    |   |
|  |    +------+-------+              +-------------+                    |   |
|  |           |                                                         |   |
|  |    +------v-------+              +-------------+                    |   |
|  |    |  Private      |              |  Private      |                    |   |
|  |    |  Subnet       |              |  Subnet       |                    |   |
|  |    |  AZ-a         |              |  AZ-b         |                    |   |
|  |    | 10.0.10.0/24  |              |10.0.20.0/24   |                    |   |
|  |    |               |              |               |                    |   |
|  |    | +---------+   |  <---ASG-->  | +---------+   |                    |   |
|  |    | |   EC2   |   |              | |   EC2   |   |                    |   |
|  |    | | (min:2) |   |              | | (max:6) |   |                    |   |
|  |    | +---------+   |              | +---------+   |                    |   |
|  |    +---------------+              +---------------+                    |   |
|  |                                                                    |   |
|  +-------------------------------------------------------------------+   |
|                                                                           |
|  +--------------+    +--------------+    +--------------+                 |
|  |  GuardDuty   |    |  CloudWatch  |    |  S3 Backend  |                 |
|  |  (Threats)   |    |  (Metrics)   |    | (TF State)   |                 |
|  +--------------+    +--------------+    +--------------+                 |
+---------------------------------------------------------------------------+
```

---

## What Sets This Apart

| Feature | What It Shows |
|---------|--------------|
| 5 Architecture Decision Records | Every design choice documented with tradeoffs and alternatives |
| 7-Scenario Operational Runbook | Copy-paste CLI commands for 3 AM troubleshooting |
| Incident Response Procedure | Full lifecycle: Detect, Triage, Mitigate, Resolve, Document |
| Security-First CI/CD | tfsec on every push, zero AWS credentials in CI |
| Security Decisions Document | Every firewall rule has a documented reason |
| Dev vs Prod Cost Comparison | FinOps thinking applied to every resource |
| 50+ Progressive Commits | Real iteration history, not a code dump |

---

## Project Structure

| Folder | Description | Key Concepts |
|--------|-------------|-------------|
| `01-s3-bucket/` | S3 state backend | Remote state, versioning |
| `02-vpc/` | Basic VPC | Subnets, route tables, IGW |
| `03-modules/` | Reusable modules | Module design, variables, DRY |
| `04-advanced-hcl/` | Advanced patterns | Workspaces, conditionals, `lookup()` |
| `05-capstone/` | **Production VPC** | Multi-AZ, ASG, GuardDuty, CI/CD, full ops docs |

Each phase builds on the previous one, progressing from basic resources to a production-style, multi-AZ infrastructure with monitoring, security, and operational documentation.

---

## Estimated Monthly Cost

| Resource | Dev ($/mo) | Prod ($/mo) | Notes |
|----------|-----------|------------|-------|
| EC2 t3.micro x2 | ~$15 | ~$46 (x6 max) | Free Tier: 750 hrs/mo for first 12 months |
| NAT Gateway | ~$32 | ~$64 (HA, 2 AZs) | Biggest single cost; see ADR-003 |
| ALB | n/a | ~$16 | Not deployed in dev; prod needs it |
| S3 (state bucket) | <$1 | <$1 | Versioning + encryption |
| GuardDuty | ~$5 | ~$5 | Per-account pricing |
| CloudWatch | <$1 | ~$3 | Alarms + dashboard |
| **Total** | **~$53** | **~$135** | |

---

## Documentation

All documentation lives in the capstone project:

- [Architecture Decision Records](./05-capstone/docs/adr/README.md) - 5 ADRs covering VPC, ASG, NAT, CI/CD, and remote state
- [Operational Runbook](./05-capstone/docs/RUNBOOK.md) - Deployment + 5 incident procedures
- [Incident Response](./05-capstone/docs/INCIDENT-RESPONSE.md) - Severity definitions, lifecycle, communication templates
- [Security Decisions](./05-capstone/docs/SECURITY-DECISIONS.md) - Why every SG rule exists
- [Backend Setup Guide](./backend-setup/README.md) - S3 remote state bootstrap runbook

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

| Certification | Status | Target |
|---------------|--------|--------|
| AWS Cloud Practitioner (CLF-C02) | In Progress | 2026 |
| HashiCorp Terraform Associate | Planned | 2026 |
| AWS Solutions Architect Associate | Planned | 2026-2027 |

---

## Contact

- **LinkedIn:** [linkedin.com/in/victor-david-medina](https://linkedin.com/in/victor-david-medina)
- **GitHub:** [github.com/Victor-David-Medina](https://github.com/Victor-David-Medina)
- **Email:** [v.davidmedina@gmail.com](mailto:v.davidmedina@gmail.com)
- **Location:** Boston, MA

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
