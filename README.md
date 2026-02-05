# Terraform Portfolio – VDM Cloud Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-1.6+-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-VPC%20%7C%20EC2%20%7C%20S3-FF9900?logo=amazon-aws)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Passing-success)
![Security](https://img.shields.io/badge/Security-tfsec%20scanned-blue)

Production‑grade AWS infrastructure built with Terraform, featuring multi‑AZ VPC architecture, Auto Scaling, GuardDuty security monitoring, and comprehensive operational documentation.

---

## 🔍 What This Demonstrates

- **Infrastructure as Code** – Complete AWS environment defined in Terraform
- **Security Best Practices** – Least‑privilege security groups, GuardDuty enabled, tfsec scans in CI
- **Operational Readiness** – Runbooks, ADRs, monitoring patterns, and incident playbooks
- **Team Collaboration** – Remote state, CI/CD validation, and a reviewable change workflow

---

## 🚀 Start Here (If You Have 5 Minutes)

If you are a recruiter or hiring manager, start with:

1. **Capstone project code:** [`05-capstone/`](./05-capstone/)
2. **Capstone README:** design decisions, cost table, and documentation links
3. **Docs folder (inside capstone):**
   - Operational runbook
   - Architecture Decision Records (ADRs)
   - Any architecture diagrams you’ve added

This path shows **how I think about Day‑2 operations**, not just how I write Terraform.

---

## 🏗️ Project Structure

| Folder             | Description         | Key Concepts                          |
|--------------------|---------------------|---------------------------------------|
| `01-s3-bucket/`    | S3 state backend    | Remote state, versioning              |
| `02-vpc/`          | Basic VPC           | Subnets, route tables, IGW            |
| `03-modules/`      | Reusable modules    | Module design, variables, DRY         |
| `04-advanced-hcl/` | Advanced patterns   | Loops, conditionals, validation       |
| `05-capstone/`     | **Production VPC**  | Multi‑AZ, ASG, GuardDuty, CI/CD, docs |

Each phase builds on the previous one, moving from **basic resources** to a **production‑style, multi‑AZ infrastructure** with monitoring and security.

---

## 🌐 Capstone Highlights (`05-capstone/`)

The capstone folder demonstrates a production‑style VPC stack:

- Multi‑AZ VPC with `10.0.0.0/16` CIDR and public/private subnet segmentation
- Auto Scaling Group (2–6 instances) with CloudWatch CPU‑based scaling
- NAT Gateway for secure private subnet internet access
- Security groups with least‑privilege ingress/egress rules
- GuardDuty threat detection enabled
- S3 remote state with DynamoDB locking
- GitHub Actions CI/CD (terraform **fmt → validate → tfsec → plan**)
- Runbook and ADRs to show operational and architectural decision‑making

---
