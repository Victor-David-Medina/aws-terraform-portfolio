# modules/compute/main.tf
# Auto Scaling Group with launch template for elastic compute capacity
#
# Design decisions documented in: docs/ADR-002-auto-scaling.md
# - Min 2 instances across AZs for high availability
# - Max 6 instances as cost cap for demo environment
# - Target tracking on CPU at 70% for responsive scaling

# -----------------------------------------------------------------------------
# DATA SOURCE: Latest Amazon Linux 2023 AMI
# Using SSM parameter avoids hardcoding AMI IDs that change per region
# -----------------------------------------------------------------------------
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# -----------------------------------------------------------------------------
# LAUNCH TEMPLATE
# Defines the instance configuration that ASG uses to launch new instances
# Separated from ASG so template can be versioned independently
# -----------------------------------------------------------------------------
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type

  # Associate with web security group for HTTP/HTTPS access
  vpc_security_group_ids = [var.security_group_id]

  # User data installs a basic web server for health check validation
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>VDM Cloud - $(hostname)</h1>" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-${var.environment}-app"
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-launch-template"
  }
}

# -----------------------------------------------------------------------------
# AUTO SCALING GROUP
# Distributes instances across private subnets in multiple AZs
# Uses target tracking to maintain CPU utilization near 70%
# -----------------------------------------------------------------------------
resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-${var.environment}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.private_subnet_ids

  # Health check grace period gives instances time to boot and pass checks
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-asg"
    propagate_at_launch = false
  }
}

# -----------------------------------------------------------------------------
# TARGET TRACKING SCALING POLICY
# AWS manages both scale-out and scale-in based on CPU target
# Simpler than step scaling and handles most web workload patterns well
# See ADR-002 for alternatives considered
# -----------------------------------------------------------------------------
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${var.project_name}-${var.environment}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.target_cpu
  }
}
