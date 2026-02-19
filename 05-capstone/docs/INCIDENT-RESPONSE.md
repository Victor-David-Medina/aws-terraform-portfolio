# Incident Response Procedure

How this team detects, triages, mitigates, resolves, and documents incidents. Follows the Detect → Triage → Mitigate → Resolve → Document lifecycle used by cloud operations teams at scale.

---

## Severity Definitions

| Level | Name | Definition | Response Time | Example |
|-------|------|-----------|---------------|--------|
| SEV-1 | Critical | Production down. All users affected. No workaround. | Immediate (< 15 min) | ASG at 0 instances, VPC unreachable |
| SEV-2 | Degraded | Service running but impaired. Partial user impact. | < 30 min | CPU alarm sustained, instances failing health checks |
| SEV-3 | Minor | Issue exists but workaround available. Limited impact. | < 4 hours | tfsec finding, single instance unhealthy but ASG compensates |
| SEV-4 | Cosmetic | No user impact. Housekeeping item. | Next business day | Budget threshold warning, documentation gap |

**Rule of thumb:** If you're unsure between two levels, pick the higher severity. It's easier to downgrade than to recover from a slow response.

---

## Incident Lifecycle

### Phase 1: Detect

**What happens:** Something triggers an alert — a CloudWatch alarm, GuardDuty finding, budget notification, or a human noticing degraded behavior.

**Who:** Monitoring systems (automated) or on-call engineer (manual observation).

**Tools:** CloudWatch Alarms, GuardDuty, AWS Budgets, GitHub Actions status checks.

**Output:** An alert with enough context to begin triage: what metric, what threshold, when it started.

### Phase 2: Triage

**What happens:** The on-call engineer assesses severity, identifies the affected component, and decides on immediate action. This is a 5-minute decision, not a 30-minute investigation.

**Who:** On-call engineer.

**Key questions:**
- Is the service down or degraded? → Sets severity level
- Which component? → VPC, ASG, NAT, GuardDuty, CI/CD, or cost
- Is this getting worse? → Determines urgency of mitigation

**Output:** Severity assignment and a one-line problem statement (e.g., "SEV-2: ASG stuck at max capacity, CPU at 95% for 20 minutes").

### Phase 3: Mitigate

**What happens:** Stop the bleeding. Mitigate first, root-cause later. The goal is to restore service, not to understand why it broke.

**Who:** On-call engineer. Escalate if mitigation isn't working within 15 minutes.

**Common mitigations:**
- ASG issues → Check launch template, verify subnet capacity, confirm IAM profile
- GuardDuty HIGH → Isolate the instance (swap to empty SG), let ASG replace it
- Cost spike → Identify and terminate orphaned resources
- CI/CD → Failures don't affect production; fix on next push

**Output:** Service restored (even if temporarily). Document what you did.

### Phase 4: Resolve

**What happens:** Identify and fix the root cause so it doesn't recur. This may involve code changes, Terraform updates, or configuration adjustments.

**Who:** On-call engineer + team lead for SEV-1/SEV-2.

**Tools:** CloudTrail (who changed what), VPC Flow Logs (network analysis), `terraform plan` (drift detection).

**Output:** A permanent fix deployed and verified. The alert should clear on its own.

### Phase 5: Document

**What happens:** Write the post-incident review within 48 hours. This is blameless — we document what the system did, not who made a mistake.

**Who:** Incident lead (whoever triaged the incident).

**Output:** A completed post-incident review using the template below.

---

## Communication Template

Use this format for all incident updates (Slack, email, or status page):

```
INCIDENT UPDATE — [SEV-X] [Component]
WHAT: [One sentence describing the issue]
WHO:  [Which users/services are affected]
DOING: [What we are doing right now]
NEXT: [When the next update will be posted]

Example:
INCIDENT UPDATE — SEV-2 ASG
WHAT: Auto Scaling Group stuck at max capacity (6/6), CPU sustained at 92%.
WHO:  All application users experiencing slow response times.
DOING: Investigating whether a traffic spike or a runaway process is driving load.
NEXT: Update in 15 minutes or when status changes.
```

Post updates at the cadence matching the severity: SEV-1 every 15 min, SEV-2 every 30 min, SEV-3 every 2 hours, SEV-4 async.

---

## Post-Incident Review Template (Blameless)

```markdown
# Post-Incident Review: [Title]
Date: YYYY-MM-DD
Severity: SEV-X
Duration: X minutes
Lead: [Name]

## Timeline
| Time (UTC) | Event |
|------------|-------|
| HH:MM | Alert fired: [description] |
| HH:MM | On-call acknowledged, began triage |
| HH:MM | Mitigation applied: [action taken] |
| HH:MM | Service restored |
| HH:MM | Root cause identified: [description] |

## What Went Well
- [Specific thing that helped — fast detection, good runbook, etc.]

## What To Improve
- [Specific gap — missing alarm, unclear runbook step, slow detection]

## Action Items
| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| [Specific fix] | [Name] | YYYY-MM-DD | Open |
```

**Rules:** No blame language ("John forgot to..."). Focus on systems ("The monitoring gap allowed..."). Every "What To Improve" item must have a matching action item with an owner.

---

## Escalation Matrix

| Situation | Action |
|-----------|--------|
| You can diagnose and fix it within 15 minutes | Handle solo. Document afterward. |
| SEV-1 or SEV-2 not improving after 15 minutes | Escalate to team lead immediately |
| GuardDuty HIGH/CRITICAL finding | Isolate first, then escalate immediately |
| You're unsure of the severity | Escalate. "I paged you because I wasn't sure" is always acceptable. |
| Cost >150% of budget with unknown source | Escalate. Consider emergency teardown of non-critical resources. |

**How to escalate:** Include these three things: (1) what's broken, (2) what you've tried, (3) what you need. Don't just say "help" — give the next person a running start.
