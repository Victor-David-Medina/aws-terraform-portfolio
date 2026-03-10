# Task: Add Application Load Balancer Module

## Status: Planned

## Context

The capstone project has an ASG in private subnets but no load balancer to
distribute traffic. This is documented as a production upgrade path in ADR-001
and the README cost table.

## Objective

Create a `modules/alb` module that provisions an Application Load Balancer
in public subnets, with a target group pointing at the ASG instances.

## Acceptance Criteria

- [ ] ALB created in public subnets across both AZs
- [ ] HTTP listener (port 80) forwarding to target group
- [ ] HTTPS listener (port 443) with ACM certificate (optional, can be commented out)
- [ ] Target group with health check on `/` returning 200
- [ ] ASG attachment to target group
- [ ] ALB security group: HTTP/HTTPS from `0.0.0.0/0`
- [ ] Web SG updated: HTTP from ALB SG only (not `0.0.0.0/0`)
- [ ] ADR-006 drafted for ALB design decisions
- [ ] Cost table updated (~$16/mo for ALB)
- [ ] Runbook updated with ALB troubleshooting procedures

## Agent

`infra-architect` — for module design and ADR authoring

## Skills

- `tf-module-review` — validate module quality
- `security-audit` — validate SG changes
- `cost-review` — validate cost impact

## Dependencies

- VPC module (public subnet IDs)
- Security module (SG updates)
- Compute module (ASG attachment)
