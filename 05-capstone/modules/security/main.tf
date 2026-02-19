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
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Open outbound for demo. Prod: VPC endpoints for S3/DynamoDB,
  # explicit CIDR allowlists for CloudWatch, SSM, package repos.
  egress {
    description = "All outbound -- see SECURITY-DECISIONS.md S3 for prod restrictions"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-${var.environment}-web-sg" }
}

# -----------------------------------------------------------------------------
# Database Security Group (private tier)
#
# WHY these rules:
# - MySQL (3306) from web SG ONLY: security group chaining means the DB
#   trusts the application tier, not the network boundary. Even if a public
#   subnet resource is compromised, it cannot reach the database.
# - No direct internet access: private subnet + no IGW route + SG restriction
# - Open egress: same demo tradeoff as web tier (see above)
#
# See: docs/SECURITY-DECISIONS.md S2 (Database SG)
# -----------------------------------------------------------------------------
resource "aws_security_group" "db" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "DB tier -- MySQL from web SG only (SG chaining). See docs/SECURITY-DECISIONS.md"
  vpc_id      = var.vpc_id

  # Ingress: MySQL from web tier only -- SG chaining, defense in depth.
  # The source is the web SG ID, not a CIDR. This means only instances
  # that are members of the web SG can reach port 3306.
  ingress {
    description     = "MySQL from web tier only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  # Egress: Open outbound for demo. Prod: restrict to specific endpoints
  # needed for RDS updates and Secrets Manager credential rotation.
  egress {
    description = "All outbound -- see SECURITY-DECISIONS.md S3 for prod restrictions"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-${var.environment}-db-sg" }
}
