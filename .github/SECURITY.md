# Security Policy

## Reporting a Vulnerability

If you find a security issue in this project, please report it responsibly.

**Email:** [v.davidmedina@gmail.com](mailto:v.davidmedina@gmail.com)

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact

I'll respond within 48 hours and work with you on a fix before any public disclosure.

## Scope

This is a portfolio/demo project and is not deployed in production. Security findings in the Terraform code (e.g., overly permissive security groups, open egress) are documented as intentional tradeoffs in [SECURITY-DECISIONS.md](05-capstone/docs/SECURITY-DECISIONS.md).

## Security Scanning

This project runs [tfsec](https://aquasecurity.github.io/tfsec/) on every push via GitHub Actions. Findings are visible in PR checks. See [ADR-004](05-capstone/docs/adr/ADR-004-security-first-cicd.md) for the CI/CD security design.
