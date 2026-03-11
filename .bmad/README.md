# BMAD Methodology - VDM Cloud Infrastructure

This directory contains the BMAD (BMad Agent-Driven) methodology configuration
for AI-assisted infrastructure development on this portfolio project.

## Structure

```
.bmad/
├── agents/              # Agent role definitions
│   ├── infra-architect.md    # Architecture design and module review
│   ├── security-reviewer.md  # Security posture and compliance
│   └── ops-engineer.md       # Operational readiness and Day-2 ops
├── skills/              # Reusable skill procedures
│   ├── tf-module-review.md   # Terraform module quality review
│   ├── security-audit.md     # Security audit procedure
│   └── cost-review.md        # FinOps and cost review
├── checklists/          # Quality gate checklists
│   ├── new-module.md         # Adding a new Terraform module
│   └── pr-review.md          # Pull request review criteria
└── tasks/               # Planned work items
    └── add-alb-module.md     # Next: Application Load Balancer
```

## How It Works

**Agents** define specialized roles with clear responsibilities and standards.
When working on infrastructure changes, activate the relevant agent to get
focused guidance:

- Making architecture changes? `infra-architect`
- Modifying security rules? `security-reviewer`
- Updating monitoring or runbooks? `ops-engineer`

**Skills** are reusable procedures that agents invoke. They provide step-by-step
evaluation criteria with concrete pass/fail checks.

**Checklists** are quality gates used before merging changes. They ensure
consistency across the project.

**Tasks** capture planned work with acceptance criteria, agent assignments,
and skill references.

## Usage with Claude Code

Reference agents and skills in your prompts:

```
"Review the VPC module using the infra-architect agent and tf-module-review skill"
"Run a security-audit on the security module changes"
"Check this PR against the pr-review checklist"
```
