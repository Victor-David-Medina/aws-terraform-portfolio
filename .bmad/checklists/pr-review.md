# Checklist: Pull Request Review

Use this checklist when reviewing pull requests to this repository.

## Code Quality
- [ ] `terraform fmt` applied (no formatting issues)
- [ ] `terraform validate` passes for affected phases
- [ ] No new `tfsec` findings (or findings documented and accepted)
- [ ] Variable descriptions are meaningful (not just restating the name)
- [ ] Comments explain "why" not "what"
- [ ] No dead code, commented-out resources, or TODO placeholders

## Naming and Tagging
- [ ] Resource names follow `${project_name}-${environment}-${resource_type}` pattern
- [ ] All resources have consistent tags via `merge(var.common_tags, {...})`
- [ ] No orphaned tags or inconsistent tag keys

## Security
- [ ] No new SG rules without documented rationale
- [ ] No `0.0.0.0/0` ingress without justification
- [ ] No hardcoded secrets, emails, or credentials in defaults
- [ ] IMDSv2 enforced on any new compute resources
- [ ] `.tfvars` files not included in the diff

## Documentation
- [ ] ADR created for architectural decisions with trade-offs
- [ ] README updated if project structure changed
- [ ] Runbook updated if operational procedures affected
- [ ] Cost table updated if new billable resources added

## Operational Readiness
- [ ] Monitoring covers new resources (CloudWatch alarms)
- [ ] Budget impact assessed
- [ ] Rollback path understood (can `terraform destroy` cleanly remove?)
- [ ] No state file conflicts or backend issues
