# Checklist: New Terraform Module

Use this checklist when adding a new module to the capstone project.

## Pre-Implementation
- [ ] ADR drafted if the module involves architectural trade-offs
- [ ] Module responsibility is single and well-defined
- [ ] Input/output contract designed (what does this module need? what does it expose?)

## File Structure
- [ ] `main.tf` created with header comment explaining module purpose
- [ ] `variables.tf` created with all inputs typed, described, and validated
- [ ] `outputs.tf` created with all outputs described with use cases

## Implementation
- [ ] Resource naming follows `${var.project_name}-${var.environment}-${resource_type}`
- [ ] All resources tagged with `merge(var.common_tags, {...})` pattern
- [ ] Tags include: Name, Environment, Project, ManagedBy, Component
- [ ] Comments explain "why" with references to ADRs or security docs
- [ ] No hardcoded values — use variables or data sources
- [ ] `depends_on` only where implicit dependencies are insufficient

## Integration
- [ ] Module added to root `main.tf` with section header comment
- [ ] Module outputs wired to root `outputs.tf`
- [ ] New variables added to root `variables.tf` if needed
- [ ] `terraform.tfvars.example` updated with new variable examples

## Security
- [ ] Security review completed (see `security-audit` skill)
- [ ] No secrets in defaults or committed files
- [ ] Network access follows least-privilege
- [ ] IMDSv2 enforced on any compute resources

## Documentation
- [ ] ADR finalized and linked from `docs/adr/README.md`
- [ ] Runbook updated if module affects operations
- [ ] README cost table updated with new resource costs
- [ ] SECURITY-DECISIONS.md updated if new SG rules added

## Validation
- [ ] `terraform fmt -check` passes
- [ ] `terraform validate` passes
- [ ] `tfsec` scan shows no new critical findings
- [ ] CI pipeline passes
