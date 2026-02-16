# Terraform Portfolio – VDM Cloud Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-1.6+-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-VPC%20%7C%20EC2%20%7C%20S3-FF9900?logo=amazon-aws)
![Terraform CI](https://github.com/Victor-David-Medina/aws-terraform-portfolio/actions/workflows/terraform.yml/badge.svg)
![Security](https://img.shields.io/badge/Security-tfsec%20scanned-blue)

Production-grade AWS infrastructure built with Terraform, featuring multi-AZ VPC architecture, Auto Scaling, GuardDuty security monitoring, and comprehensive operational documentation.

---

## About Me

Operations engineer with 8+ years leading enterprise system deployments, now building cloud infrastructure with Terraform and AWS. My background in logistics operations (USMC), SaaS platform rollouts (ezCater), and healthcare compliance (Amwell) gives me a strong foundation in reliability, process documentation, and incident response — the same skills that drive effective cloud operations.

---

## What This Demonstrates

- **Infrastructure as Code** – Complete AWS environment defined in Terraform with modular design
- **Security Best Practices** – Least-privilege security groups, GuardDuty threat detection, tfsec scans in CI
- **Operational Readiness** – Runbooks, ADRs, monitoring alarms, cost governance, and incident playbooks
- **Team Collaboration** – Remote state configuration, CI/CD validation, and reviewable change workflow

---

## Start Here (If You Have 5 Minutes)

If you are a recruiter or hiring manager, start with:

1. **Capstone project code:** [`05-capstone/`](./05-capstone/)
2. **Capstone README:** design decisions, cost table, and documentation links
3. **Docs folder (inside capstone):**
   - Operational runbook
   - Architecture Decision Records (ADRs)

This path shows **how I think about Day-2 operations**, not just how I write Terraform.

---

## Project Structure

| Folder             | Description         | Key Concepts                          |
|--------------------|---------------------|---------------------------------------|
| `01-s3-bucket/`    | S3 state backend    | Remote state, versioning              |
| `02-vpc/`          | Basic VPC           | Subnets, route tables, IGW            |
| `03-modules/`      | Reusable modules    | Module design, variables, DRY         |
| `04-advanced-hcl/` | Advanced patterns   | Loops, conditionals, validation       |
| `05-capstone/`     | **Production VPC**  | Multi-AZ, ASG, GuardDuty, CI/CD, docs |

Each phase builds on the previous one, moving from **basic resources** to a **production-style, multi-AZ infrastructure** with monitoring and security.

---

## Capstone Highlights (`05-capstone/`)

The capstone folder demonstrates a production-style VPC stack:

- Multi-AZ VPC with `10.0.0.0/16` CIDR and public/private subnet segmentation
- Auto Scaling Group (2–6 instances) with CPU-based target tracking
- NAT Gateway for secure private subnet internet access
- Security groups with least-privilege ingress/egress rules
- GuardDuty threat detection for continuous security monitoring
- CloudWatch alarms for scaling visibility and cost optimization
- AWS Budget alerts for cost governance
- S3 remote state with DynamoDB locking (backend config included)
- GitHub Actions CI/CD (terraform **fmt → validate → tfsec → plan**)
- Runbook and ADRs to show operational and architectural decision-making

---

## Technologies

| Category | Tools |
|----------|-------|
| IaC | Terraform 1.6+, HCL |
| Cloud | AWS (VPC, EC2, ASG, S3, DynamoDB, GuardDuty, CloudWatch, Budgets) |
| CI/CD | GitHub Actions |
| Security | tfsec, least-privilege security groups |
| Documentation | ADRs, operational runbooks, cost tables |

---

## Certifications

- **AWS Cloud Practitioner (CLF-C02)** – In Progress
- **HashiCorp Terraform Associate (004)** – Planned

---

## Contact

- **LinkedIn:** [linkedin.com/in/victor-david-medina](https://linkedin.com/in/victor-david-medina)
- **Email:** [v.davidmedina@gmail.com](mailto:v.davidmedina@gmail.com)
- **Location:** Boston, MA

