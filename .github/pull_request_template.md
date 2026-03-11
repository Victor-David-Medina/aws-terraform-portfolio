## Summary

<!-- What does this PR change and why? -->

## Changes

-

## Checklist

- [ ] `terraform fmt -check -recursive` passes
- [ ] `terraform validate` passes for affected phases
- [ ] No new `tfsec` findings (or findings are documented and accepted)
- [ ] Variables have `description` and `type`
- [ ] Resource naming follows `${project_name}-${environment}-${resource_type}`
- [ ] Tags use `merge(var.common_tags, {...})` pattern
- [ ] No hardcoded secrets or credentials
- [ ] ADR created if this involves architectural tradeoffs
- [ ] README and cost table updated if new resources added
- [ ] Runbook updated if operational procedures affected
