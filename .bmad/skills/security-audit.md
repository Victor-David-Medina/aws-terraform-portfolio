# Skill: Security Audit

## Purpose

Perform a security audit of the infrastructure codebase, validating network
isolation, access controls, data protection, and compliance with documented
security decisions.

## Inputs

- **scope**: `network` (SGs and VPC), `compute` (EC2 and ASG), `data` (S3 and state), or `full` (all)
- **environment**: `dev`, `staging`, or `prod` (affects acceptable risk thresholds)

## Procedure

### 1. Network Security

#### Security Groups
For each security group:
- [ ] Every ingress rule has a `description` field
- [ ] Every egress rule has a `description` field
- [ ] `0.0.0.0/0` ingress rules are justified and documented in SECURITY-DECISIONS.md
- [ ] Inter-tier rules use security group IDs (chaining), not CIDRs
- [ ] No SSH (port 22) rules — SSM Session Manager required
- [ ] No overly broad port ranges (e.g., 0-65535)

#### VPC Design
- [ ] Private subnets have no `map_public_ip_on_launch`
- [ ] Private subnets route through NAT Gateway (no direct IGW route)
- [ ] Public subnets are limited to load balancers and NAT Gateways
- [ ] Route tables are explicitly associated (no default main RT usage)

### 2. Compute Security
- [ ] Launch templates enforce IMDSv2 (`http_tokens = "required"`)
- [ ] Instances are placed in private subnets
- [ ] User data scripts contain no hardcoded secrets
- [ ] Security group attachment is explicit (not default VPC SG)

### 3. Data Security
- [ ] S3 buckets block public access (all 4 settings)
- [ ] State bucket has versioning enabled
- [ ] No sensitive values in variable defaults
- [ ] `.tfvars` files are gitignored
- [ ] No credentials in any committed file

### 4. Monitoring and Detection
- [ ] GuardDuty is enabled
- [ ] S3 data source monitoring is enabled on GuardDuty
- [ ] CloudWatch alarms exist for critical metrics
- [ ] Budget alerts are configured

### 5. Cross-Reference
- [ ] All SG rules map to entries in SECURITY-DECISIONS.md
- [ ] Open egress rules have documented production upgrade path
- [ ] Demo-only configurations are clearly labeled

## Output Format

```
## Security Audit Report

**Environment**: <env>
**Date**: <date>
**Overall Rating**: <Critical / Warning / Pass>

### Findings

| Category | Status | Severity | Finding |
|----------|--------|----------|---------|
| Network | ... | ... | ... |

### Critical Items
<items requiring immediate action>

### Recommendations
<items for future improvement>

### Production Upgrade Path
<what would change for prod deployment>
```
