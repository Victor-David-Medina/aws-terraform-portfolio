# Production VPC Infrastructure

Multi-AZ AWS VPC with Auto Scaling, security monitoring, and operational documentation.

## Problem Statement

Organizations need scalable, secure VPC infrastructure that can be version-controlled, reviewed, and deployed consistently. This project demonstrates production patterns for AWS networking with Terraform.

## Architecture Decisions

| Component | Choice | Rationale |

|-----------|--------|-----------|

| VPC CIDR | 10.0.0.0/16 | 65K IPs for growth |

| Subnets | Public + Private per AZ | Security isolation |

| NAT Gateway | Single (not HA) | Cost optimization for demo |

| ASG | 2-6 instances, 70% CPU | Balance responsiveness/cost |

| Security | GuardDuty + SGs | Defense in depth |

## Quick Start

```bash

git clone https://github.com/Victor-David-Medina/aws-terraform-portfolio.git

cd aws-terraform-portfolio/05-capstone

cp terraform.tfvars.example terraform.tfvars

terraform init && terraform plan

```

## Estimated Monthly Cost

| Resource | Cost |

|----------|------|

| NAT Gateway | ~$32 |

| EC2 t3.micro x2 | ~$15 |

| GuardDuty | ~$5 |

| S3 + DynamoDB | <$1 |

| **Total** | **~$53/month** |

## Documentation

- [RUNBOOK.md](docs/RUNBOOK.md) - Deployment and troubleshooting

- [ADR-001](docs/ADR-001-vpc-design.md) - VPC architecture decisions

- [ADR-002](docs/ADR-002-auto-scaling.md) - Auto Scaling strategy
