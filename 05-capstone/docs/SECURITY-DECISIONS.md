# Security Decisions

Why every firewall rule in this project exists, what it prevents, and what production would do differently. Each security group rule is an intentional decision, not a default.

---

## 1. Web Security Group — Public-Facing Tier

**What we chose:** Allow inbound TCP 80 (HTTP) and 443 (HTTPS) only. Ingress source is the ALB security group, not `0.0.0.0/0`.

**Why:** The EC2 instances sit in private subnets behind a load balancer. Allowing traffic only from the ALB's security group means the instances are unreachable directly from the internet, even if someone discovers their private IPs through a misconfigured VPC peering or DNS leak. This is defense-in-depth: the ALB handles TLS termination and connection filtering before traffic ever reaches the application layer.

Restricting to ports 80/443 eliminates entire attack classes — no SSH brute-force attempts, no database port scanning, no SMTP abuse. If the application doesn't listen on a port, that port doesn't need to be open.

**What production would do differently:** Add AWS WAF in front of the ALB to filter OWASP Top 10 attacks (SQLi, XSS, etc.). Rate-limit by IP. Restrict to 443-only and redirect 80 → 443 at the ALB listener level. Consider AWS Shield Advanced for DDoS protection on critical services.

---

## 2. Database Security Group — Private Tier

**What we chose:** Allow inbound TCP 3306 (MySQL) only from the web security group. No other ingress. No direct internet access.

**Why:** This is security group chaining — the database tier trusts only the application tier, not the network boundary. Even if an attacker compromises a public subnet resource, they cannot reach the database because the source must be a member of the web security group, not just "something in the VPC."

This implements least-privilege at the network layer: the database only speaks MySQL, and only to the application servers that need it. Combined with private subnets (no public IP, no IGW route), the database has no path to the internet in either direction.

**What production would do differently:** Use RDS with IAM database authentication instead of password-based auth. Enable RDS encryption at rest (KMS). Use Secrets Manager for credential rotation. Add VPC endpoints for Secrets Manager access so the credential path never crosses the internet. Consider Aurora with read replicas for the database tier if read scaling is needed.

---

## 3. Egress Rules — Outbound Traffic

**What we chose:** Allow all outbound traffic (`0.0.0.0/0`) from both web and database security groups.

**Why this is acceptable for demo:** In a learning environment, unrestricted egress simplifies package installation (`yum update`, `pip install`), CloudWatch agent communication, and SSM Session Manager connectivity. Restricting egress in a demo adds complexity without demonstrating new security concepts — the interesting outbound restrictions (VPC endpoints, NAT-filtered egress) are infrastructure patterns, not security group rules.

**Why this is NOT acceptable for production:** Unrestricted egress is how compromised instances exfiltrate data, communicate with C2 servers, and participate in botnets. A compromised instance with `0.0.0.0/0` egress can send stolen credentials anywhere on the internet.

**What production would do differently:**
- **VPC endpoints** for S3 and DynamoDB — traffic stays on the AWS backbone, never crosses the NAT Gateway or internet. Saves data processing costs and removes an exfiltration path.
- **NAT Gateway egress filtering** — All private subnet outbound traffic already routes through the single NAT GW (see ADR-003), which provides a natural choke point for VPC Flow Log analysis.
- **Explicit CIDR allowlists** — Restrict egress to known endpoints: CloudWatch (`monitoring.us-east-1.amazonaws.com`), SSM (`ssm.us-east-1.amazonaws.com`), specific package repositories.
- **DNS firewall** — Block outbound DNS resolution to known-malicious domains using Route 53 Resolver DNS Firewall.

---

## 4. Instance Access Pattern — No SSH, No Bastion

**What we chose:** No port 22 (SSH) in any security group. No bastion host. Access via AWS Systems Manager (SSM) Session Manager.

**Why:** SSH key management is the single biggest operational security burden for EC2 fleets. Keys get shared, stored in plaintext, copied to laptops, and never rotated. A bastion host is another server to patch, monitor, and pay for ($8/mo for a t3.micro running 24/7) — and it becomes a high-value target because it has network access to everything.

SSM Session Manager eliminates all of this: no SSH keys to manage, no port 22 to open, no bastion to maintain, and every session is logged to CloudTrail with the IAM identity of who connected. The audit trail is automatic and immutable.

**What production would do differently:** SSM Session Manager IS the production pattern — this is one area where the demo matches production best practice. Additionally: enable SSM session logging to S3 for long-term retention, require MFA for `ssm:StartSession` IAM permissions, and use SSM Run Command instead of interactive sessions for routine operations (patching, log collection).

---

## 5. tfsec `soft_fail` in CI/CD Pipeline

**What we chose:** `tfsec` runs with `soft_fail: true` in the GitHub Actions pipeline (see ADR-004). Findings are reported but don't block the PR from merging.

**Why for demo:** A demo/portfolio project intentionally makes tradeoffs that tfsec flags — single NAT Gateway (ADR-003), open egress rules (above), no S3 access logging on the state bucket. These are documented decisions with rationale, not oversights. Blocking every PR on findings that we've already evaluated creates noise without adding safety.

**Why this is NOT acceptable for production:** In production, `soft_fail: false` is mandatory. Every finding that isn't a true false positive must be fixed before merge. Findings that are genuinely acceptable for the environment get an inline exception with a comment explaining why:

```hcl
#tfsec:ignore:aws-s3-enable-bucket-logging -- State bucket access
# is audited via CloudTrail S3 data events instead of S3 access logs.
# See ADR-005 for rationale.
resource "aws_s3_bucket" "state" {
  bucket = "vdm-terraform-state"
}
```

**What production would do differently:** Replace tfsec with Trivy (tfsec's successor, see ADR-004 deprecation note). Set `soft_fail: false`. Require all inline ignores to include a comment referencing the ADR or security review that approved the exception. Run Trivy in both PR and main-branch pipelines. Add Checkov as a second scanner for CIS benchmark coverage.
