# Skill: Terraform Module Review

## Purpose

Evaluate a Terraform module for quality, consistency, and adherence to project
conventions. This skill checks structure, naming, variables, outputs, tagging,
and documentation.

## Inputs

- **module_path**: Path to the module directory (e.g., `05-capstone/modules/vpc`)
- **scope**: `full` (all checks) or `quick` (structure and naming only)

## Procedure

### 1. File Structure Check
Verify the module contains the standard files:
- [ ] `main.tf` - Resource definitions
- [ ] `variables.tf` - Input variable declarations
- [ ] `outputs.tf` - Output value declarations

Flag any additional files and confirm they serve a clear purpose.

### 2. Variable Quality
For each variable in `variables.tf`:
- [ ] Has `description` that explains purpose (not just restates the name)
- [ ] Has explicit `type` declaration
- [ ] Has `default` value where appropriate (required vars should NOT have defaults)
- [ ] Has `validation` block for constrained inputs (environment, CIDR, etc.)
- [ ] No hardcoded sensitive values in defaults (emails, IPs, credentials)

### 3. Resource Naming
For each resource in `main.tf`:
- [ ] Name tag follows: `${var.project_name}-${var.environment}-${resource_type}`
- [ ] Tags include: Name, Environment, Project, ManagedBy, Component
- [ ] Uses `merge(var.common_tags, {...})` pattern for tag consistency

### 4. Output Quality
For each output in `outputs.tf`:
- [ ] Has `description` explaining what it represents and when to use it
- [ ] References a specific resource attribute (not computed values without context)
- [ ] Sensitive values marked with `sensitive = true`

### 5. Code Quality
- [ ] Comments explain "why" not "what"
- [ ] References to ADRs or security docs where decisions involve trade-offs
- [ ] No hardcoded values that should be variables
- [ ] Proper use of `count` or `for_each` for repeated resources
- [ ] `depends_on` used only when implicit dependencies are insufficient

### 6. Security Review
- [ ] No overly permissive security group rules without documented rationale
- [ ] No `0.0.0.0/0` ingress without justification
- [ ] Private resources stay in private subnets
- [ ] IMDSv2 enforced on compute resources

## Output Format

```
## Module Review: <module_name>

### Summary
<pass/fail with explanation>

### Findings
| Check | Status | Notes |
|-------|--------|-------|
| File Structure | pass/fail | ... |
| Variable Quality | pass/fail | ... |
| Resource Naming | pass/fail | ... |
| Output Quality | pass/fail | ... |
| Code Quality | pass/fail | ... |
| Security | pass/fail | ... |

### Recommendations
1. ...
2. ...
```
