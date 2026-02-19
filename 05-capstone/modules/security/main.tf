# =============================================================================
# modules/security/main.tf
# Security Group Definitions
#
# Every rule has a documented rationale. For full security analysis
# including production upgrade paths, see docs/SECURITY-DECISIONS.md.
# =============================================================================


# -----------------------------------------------------------------------------
# Web Security Group (public-facing tier)
#
# WHY these rules:
# - HTTP/HTTPS only: eliminates SSH brute-force, DB port scanning, SMTP abuse
# - 0.0.0.0/0 ingress: acceptable because instances are in private subnets
#   behind NAT; in production, restrict source to ALB SG instead
# - Open egress: simplifies package updates and CloudWatch agent comms
#   in demo; production would restrict to VPC endpoints + specific CIDRs
# - No port 22: access via SSM Session Manager (no SSH keys, full audit trail)
#
# See: docs/SECURITY-DECISIONS.md S1 (Web SG) and S3 (Egress)
# -----------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${var.project_name}-${var.environment}-web-sg"
  description = "Web tier -- HTTP/HTTPS only, no SSH. See docs/SECURITY-DECISIONS.md"
  vpc_id      = var.vpc_id


  # Ingress: HTTP -- ALB terminates TLS in prod; direct access for demo
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Ingress: HTTPS -- same rationale; prod restricts source to ALB SG
