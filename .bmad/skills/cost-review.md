# Skill: Cost Review

## Purpose

Evaluate infrastructure changes for cost impact, validate FinOps best practices,
and ensure budget governance is in place. Compares dev vs prod cost profiles
and identifies optimization opportunities.

## Inputs

- **change_type**: `new_resource`, `modification`, or `full_audit`
- **environment**: `dev`, `staging`, or `prod`

## Procedure

### 1. Resource Cost Assessment
For each resource in the change:
- [ ] Identify the AWS pricing model (on-demand, reserved, spot)
- [ ] Estimate monthly cost for dev configuration
- [ ] Estimate monthly cost for prod configuration
- [ ] Check Free Tier eligibility (first 12 months)
- [ ] Flag any resources with usage-based pricing (NAT Gateway data transfer, etc.)

### 2. Right-Sizing Review
- [ ] Instance types are appropriate for workload (not over-provisioned)
- [ ] ASG min/max/desired are reasonable for the environment
- [ ] Single NAT Gateway for dev (documented multi-NAT for prod)
- [ ] No unnecessary resources running in dev that are prod-only

### 3. Budget Governance
- [ ] AWS Budget resource exists with monthly limit
- [ ] Alert thresholds at 80% (warning) and 100% (critical)
- [ ] Budget notification emails configured (via tfvars, not hardcoded)
- [ ] Cost allocation tags applied to all resources

### 4. Cost Table Validation
Verify README cost table reflects current infrastructure:
- [ ] All deployed resources listed
- [ ] Dev and Prod columns accurate
- [ ] Notes column explains pricing nuances
- [ ] Total is calculated correctly

### 5. Optimization Opportunities
- [ ] Spot instances considered for non-critical workloads
- [ ] Reserved instances considered for stable workloads
- [ ] S3 lifecycle policies for log rotation
- [ ] CloudWatch log retention periods set

## Output Format

```
## Cost Review

### Monthly Estimate
| Resource | Dev ($/mo) | Prod ($/mo) | Change |
|----------|-----------|------------|--------|
| ... | ... | ... | ... |

### Budget Status
- Limit: $X/mo
- Current projected: $Y/mo
- Alerts: configured/missing

### Optimization Opportunities
1. ...
2. ...

### Risk Items
<any costs that could spike unexpectedly>
```
