# Operational Runbook

Deployment procedures, troubleshooting guides, and operational playbooks.

## Initial Deployment

### Pre-requisites

- [ ] AWS CLI configured with appropriate credentials
- [ ] Terraform >= 1.6.0 installed
- [ ] S3 backend bucket created (see backend-setup/)
- [ ] terraform.tfvars configured from example

### Deployment Steps

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Post-Deployment Verification

```bash
# Verify VPC and subnets created
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=VDM-Cloud-Infrastructure"

# Verify ASG instances are running
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names vdm-capstone-dev-asg

# Verify GuardDuty is active
aws guardduty list-detectors
```

## Troubleshooting

### EC2 Instances Cannot Reach Internet

1. Verify NAT Gateway status in AWS Console
2. Check route table associations for private subnets
3. Confirm security group allows outbound traffic
4. Verify the NAT Gateway's Elastic IP is allocated

### State Lock Timeout

```bash
# Check for stale locks
aws dynamodb scan --table-name terraform-state-lock

# Force unlock if needed (use with caution)
terraform force-unlock LOCK_ID
```

### ASG Not Scaling

1. Check CloudWatch alarms in AWS Console (look for cpu-high / cpu-low)
2. Verify scaling policy thresholds match ADR-002 specs (70% CPU target)
3. Review ASG activity history for errors
4. Confirm instances can pass health checks (HTTP 200 on port 80)

### GuardDuty Findings

1. Check GuardDuty console for finding severity (Low/Medium/High)
2. High severity: isolate affected instance immediately
3. Medium severity: investigate within 24 hours
4. Document findings in incident log for post-mortem review

## Teardown Procedure

```bash
# Always backup state first
terraform state pull > backup.tfstate
terraform destroy
```

## Emergency Contacts

- AWS Support: support.aws.amazon.com
- Terraform Docs: developer.hashicorp.com/terraform
