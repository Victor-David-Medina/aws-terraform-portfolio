Terraform Portfolio

![Terraform](https://img.shields.io/badge/Terraform-1.6+-623CE4?logo=terraform) ![AWS](https://img.shields.io/badge/AWS-VPC%20%7C%20EC2%20%7C%20S3-FF9900?logo=amazon-aws) ![CI/CD](https://img.shields.io/badge/CI%2FCD-Passing-success) ![Security](https://img.shields.io/badge/Security-tfsec%20scanned-blue)

Production-grade AWS infrastructure built with Terraform, featuring multi-AZ VPC architecture, Auto Scaling, GuardDuty security monitoring, and comprehensive operational documentation.

## What This Demonstrates

- **Infrastructure as Code**: Complete AWS environment defined in Terraform

- **Security Best Practices**: Least-privilege IAM, security groups, GuardDuty

- **Operational Readiness**: Runbooks, ADRs, monitoring, incident playbooks

- **Team Collaboration**: Remote state, CI/CD validation, code review workflow

## Project Structure

| Folder | Description | Key Concepts |

|--------|-------------|--------------|

| `01-s3-bucket/` | S3 state backend | Remote state, versioning |

| `02-vpc/` | Basic VPC | Subnets, route tables, IGW |

| `03-modules/` | Reusable modules | Module design, variables |

| `04-advanced-hcl/` | Advanced patterns | Loops, conditionals, validation |

| `05-capstone/` | **Production VPC** | Multi-AZ, ASG, GuardDuty, CI/CD |

## Capstone Highlights

- Multi-AZ VPC with 10.0.0.0/16 CIDR, public/private subnet segmentation

- Auto Scaling Group (2-6 instances) with CloudWatch CPU-based scaling

- NAT Gateway for secure private subnet internet access

- Security groups with least-privilege ingress/egress rules

- GuardDuty threat detection enabled

- S3 remote state with DynamoDB locking

- GitHub Actions CI/CD (fmt → validate → tfsec → plan)

## Certifications

- **AWS Cloud Practitioner (CLF-C02)** - Jan 2026

- **HashiCorp Terraform Associate (004)** - Feb 2026

## Contact

- **Email**: v.davidmedina@gmail.com

- **LinkedIn**: linkedin.com/in/victor-david-medina

- **Location**: Boston, MA (Open to Remote)
