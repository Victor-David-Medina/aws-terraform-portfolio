# Contributing

Thanks for your interest in this project. Here's how to contribute.

## Development Setup

1. Install [Terraform 1.10+](https://developer.hashicorp.com/terraform/install)
2. Install [tfsec](https://aquasecurity.github.io/tfsec/) for security scanning
3. Clone the repo and create a feature branch

```bash
git clone https://github.com/Victor-David-Medina/aws-terraform-portfolio.git
cd aws-terraform-portfolio
git checkout -b feature/your-change
```

## Before Submitting a PR

Run the local CI checks:

```bash
make ci
```

Or individually:

```bash
terraform fmt -check -recursive     # formatting
tfsec .                              # security scan
cd 05-capstone && terraform init -backend=false && terraform validate
```

## Conventions

- **Naming:** `${project_name}-${environment}-${resource_type}`
- **Tagging:** Always use `merge(var.common_tags, {...})`
- **Variables:** Every variable needs `description`, `type`, and `validation` where applicable
- **Comments:** Explain the "why", not the "what". Reference ADRs when a decision involves tradeoffs.
- **Commits:** Use conventional commit prefixes (`feat:`, `fix:`, `docs:`, `style:`, `refactor:`)

## Adding a New Module

Follow the [new module checklist](.bmad/checklists/new-module.md) and use the [tf-module-review skill](.bmad/skills/tf-module-review.md) for self-review before opening a PR.

## Architecture Decisions

If your change involves a tradeoff (cost vs. availability, complexity vs. simplicity), write an ADR. See [existing ADRs](05-capstone/docs/adr/README.md) for the template.
