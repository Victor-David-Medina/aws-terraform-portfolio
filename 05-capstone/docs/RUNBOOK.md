# Operational Runbook

Deployment procedures, troubleshooting guides, and incident playbooks for the capstone VPC infrastructure.

**Audience:** On-call engineer at 3 AM. Every command is copy-paste ready.

---

## Table of Contents

1. [Initial Deployment](#initial-deployment)
2. [Troubleshooting — Common Issues](#troubleshooting)
3. [Incident Procedures](#incident-procedures)
   - [ASG Not Scaling — 0 Healthy Instances](#incident-asg-not-scaling--0-healthy-instances)
   - [CloudWatch Alarm Fired](#incident-cloudwatch-alarm-fired)
   - [GuardDuty Finding Appeared](#incident-guardduty-finding-appeared)
   - [Budget Alert Threshold Breached](#incident-budget-alert-threshold-breached)
   - [CI/CD Pipeline Failure](#incident-cicd-pipeline-failure)
4. [Teardown Procedure](#teardown-procedure)

---

## Initial Deployment

### Pre-requisites

- [ ] AWS CLI configured with appropriate credentials
- [ ] Terraform >= 1.10.0 installed (`use_lockfile` requires 1.10+)
- [ ] S3 backend bucket created (see [backend-setup/README.md](../../backend-setup/README.md))
- [ ] `terraform.tfvars` configured from example

### Deployment Steps

```bash
# From 05-capstone/
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Verify Deployment

```bash
# Confirm VPC exists
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=vdm-capstone" \
  --query "Vpcs[].{ID:VpcId,CIDR:CidrBlock,State:State}" --output table

# Confirm ASG has healthy instances
aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?contains(AutoScalingGroupName,'vdm')].{Name:AutoScalingGroupName,Desired:DesiredCapacity,Running:length(Instances)}" \
  --output table
```

---

## Troubleshooting

### EC2 Instances Cannot Reach Internet

```bash
# 1. Check NAT Gateway status
aws ec2 describe-nat-gateways \
  --filter "Name=state,Values=available,failed,deleted" \
  --query "NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId}" --output table

# 2. Check private subnet route tables have 0.0.0.0/0 → NAT GW
aws ec2 describe-route-tables \
  --filters "Name=tag:Project,Values=vdm-capstone" \
  --query "RouteTables[].{ID:RouteTableId,Routes:Routes[?DestinationCidrBlock=='0.0.0.0/0'].{Target:NatGatewayId,State:State}}" \
  --output json

# 3. Check security group allows outbound
aws ec2 describe-security-groups \
  --filters "Name=tag:Project,Values=vdm-capstone" \
  --query "SecurityGroups[].{Name:GroupName,Egress:IpPermissionsEgress[].{Protocol:IpProtocol,To:ToPort}}" \
  --output json
```

### State Lock Issues

State locking uses `use_lockfile` (S3-based `.tflock` file), not DynamoDB. See [ADR-005](../adr/ADR-005-remote-state.md).

```bash
# Check if a .tflock file exists in the state bucket
aws s3 ls s3://vdm-terraform-state/capstone/ | grep tflock

# If stale lock exists after a crashed apply:
terraform force-unlock LOCK_ID
```

---

## Incident Procedures

### Incident: ASG Not Scaling — 0 Healthy Instances

**Symptoms:** CloudWatch alarm `CPUUtilization` shows no data. Application is unreachable. ASG shows 0 InService instances. PagerDuty/email alert for unhealthy target group.

**Severity:** SEV-1 — Complete service outage. All instances are down.

**Diagnosis:**

1. Confirm the ASG state and instance count:
   ```bash
   aws autoscaling describe-auto-scaling-groups \
     --query "AutoScalingGroups[?contains(AutoScalingGroupName,'vdm')].{Name:AutoScalingGroupName,Min:MinSize,Max:MaxSize,Desired:DesiredCapacity,InService:length(Instances[?LifecycleState=='InService'])}" \
     --output table
   ```

2. Check recent scaling activities for failure reasons:
   ```bash
   aws autoscaling describe-scaling-activities \
     --auto-scaling-group-name "$(aws autoscaling describe-auto-scaling-groups \
       --query "AutoScalingGroups[?contains(AutoScalingGroupName,'vdm')].AutoScalingGroupName" \
       --output text)" \
     --max-items 10 \
     --query "Activities[].{Time:StartTime,Status:StatusCode,Cause:Cause}" \
     --output table
   ```

3. Verify the launch template is valid (AMI exists, instance type available):
   ```bash
   aws autoscaling describe-auto-scaling-groups \
     --query "AutoScalingGroups[?contains(AutoScalingGroupName,'vdm')].LaunchTemplate" \
     --output json
   # Then check the AMI:
   aws ec2 describe-images --image-ids <AMI_ID_FROM_ABOVE> \
     --query "Images[].{ID:ImageId,State:State,Name:Name}" --output table
   ```

4. Check if the subnet has available IPs:
   ```bash
   aws ec2 describe-subnets \
     --filters "Name=tag:Project,Values=vdm-capstone" "Name=tag:Tier,Values=private" \
     --query "Subnets[].{ID:SubnetId,AZ:AvailabilityZone,AvailableIPs:AvailableIpAddressCount}" \
     --output table
   ```

5. Verify the IAM instance profile exists:
   ```bash
   aws iam get-instance-profile --instance-profile-name vdm-capstone-ec2-profile \
     --query "InstanceProfile.{Name:InstanceProfileName,Role:Roles[0].RoleName}" \
     --output table
   ```

6. Check security group allows health check traffic:
   ```bash
   aws ec2 describe-security-groups \
     --filters "Name=tag:Project,Values=vdm-capstone" "Name=group-name,Values=*web*" \
     --query "SecurityGroups[].{ID:GroupId,Ingress:IpPermissions[].{Port:ToPort,Source:IpRanges[].CidrIp}}" \
     --output json
   ```

**Resolution:**

1. If AMI is deregistered → Update launch template with current Amazon Linux 2023 AMI:
   ```bash
   aws ssm get-parameter --name "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" \
     --query "Parameter.Value" --output text
   ```
2. If subnet is full → This shouldn't happen with /24 subnets (251 IPs). Check for leaked ENIs.
3. If IAM profile is missing → Run `terraform apply` to recreate it.
4. If security group blocks health checks → Run `terraform apply` to restore rules.

**Verification:**
```bash
# Wait 2-3 minutes, then confirm instances are InService
aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?contains(AutoScalingGroupName,'vdm')].{Desired:DesiredCapacity,InService:length(Instances[?LifecycleState=='InService'])}" \
  --output table
```

**Escalation:** If instances keep launching and immediately terminating (launch-terminate loop for >10 minutes), check CloudTrail for permission errors and escalate to the team lead. Do not increase `max_size` — the problem is upstream.

---

### Incident: CloudWatch Alarm Fired

**Symptoms:** Email or SNS notification from CloudWatch. Alarm name contains `vdm-capstone`. Alarm state changed to `ALARM`.

**Severity:** SEV-2 — Degraded performance. Service is running but a threshold was breached.

**Diagnosis:**

1. Identify which alarm fired and its current value:
   ```bash
   aws cloudwatch describe-alarms --state-value ALARM \
     --query "MetricAlarms[?contains(AlarmName,'vdm')].{Name:AlarmName,Metric:MetricName,Threshold:Threshold,Current:StateReason}" \
     --output table
   ```

2. Pull the metric data for the last 30 minutes to see the trend:
   ```bash
   aws cloudwatch get-metric-statistics \
     --namespace AWS/EC2 \
     --metric-name CPUUtilization \
     --dimensions Name=AutoScalingGroupName,Value="$(aws autoscaling describe-auto-scaling-groups \
       --query "AutoScalingGroups[?contains(AutoScalingGroupName,'vdm')].AutoScalingGroupName" \
       --output text)" \
     --start-time "$(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%S)" \
     --end-time "$(date -u +%Y-%m-%dT%H:%M:%S)" \
     --period 300 \
     --statistics Average Maximum \
     --output table
   ```

3. Check if the ASG is already scaling in response:
   ```bash
   aws autoscaling describe-scaling-activities \
     --auto-scaling-group-name "$(aws autoscaling describe-auto-scaling-groups \
       --query "AutoScalingGroups[?contains(AutoScalingGroupName,'vdm')].AutoScalingGroupName" \
       --output text)" \
     --max-items 5 \
     --query "Activities[].{Time:StartTime,Status:StatusCode,Cause:Cause}" \
     --output table
   ```

4. Check individual instance health:
   ```bash
   aws autoscaling describe-auto-scaling-instances \
     --query "AutoScalingInstances[?contains(AutoScalingGroupName,'vdm')].{ID:InstanceId,AZ:AvailabilityZone,Health:HealthStatus,Lifecycle:LifecycleState}" \
     --output table
   ```

**Resolution:**

1. If CPU alarm and ASG is already scaling → **No action needed.** The Target Tracking policy (70% threshold, see ADR-002) handles this automatically. Monitor for 5 minutes.
2. If CPU alarm and ASG is NOT scaling → Check if desired capacity already equals max (6). If yes, the load exceeds current capacity limits.
3. If alarm is non-CPU (custom metric) → Investigate the specific metric. Check the alarm's `MetricName` from step 1.

**Verification:**
```bash
# Wait 5 minutes for cooldown (300s per ADR-002), then check alarm state
aws cloudwatch describe-alarms \
  --alarm-names "<ALARM_NAME_FROM_STEP_1>" \
  --query "MetricAlarms[].StateValue" --output text
```

**Escalation:** If the alarm stays in `ALARM` state for >15 minutes despite ASG scaling to max, the workload has outgrown the infrastructure. Escalate to team lead to discuss increasing `max_size` or upgrading instance type.

---

### Incident: GuardDuty Finding Appeared

**Symptoms:** GuardDuty email notification or AWS console alert. Finding severity may be LOW, MEDIUM, or HIGH.

**Severity:** Depends on finding severity — SEV-3 for LOW/MEDIUM, SEV-1 for HIGH/CRITICAL.

**Diagnosis:**

1. List recent findings sorted by severity:
   ```bash
   DETECTOR_ID=$(aws guardduty list-detectors --query "DetectorIds[0]" --output text)

   aws guardduty list-findings --detector-id "$DETECTOR_ID" \
     --finding-criteria '{"Criterion":{"severity":{"Gte":4}}}' \
     --sort-criteria '{"AttributeName":"severity","OrderBy":"DESC"}' \
     --query "FindingIds" --output json
   ```

2. Get full details of the finding (replace `FINDING_ID`):
   ```bash
   aws guardduty get-findings --detector-id "$DETECTOR_ID" \
     --finding-ids "FINDING_ID" \
     --query "Findings[].{Type:Type,Severity:Severity,Title:Title,Description:Description,Resource:Resource.ResourceType,Action:Service.Action}" \
     --output json
   ```

3. Identify the affected resource:
   ```bash
   aws guardduty get-findings --detector-id "$DETECTOR_ID" \
     --finding-ids "FINDING_ID" \
     --query "Findings[].Resource.InstanceDetails.{ID:InstanceId,IP:NetworkInterfaces[0].PrivateIpAddress,SG:SecurityGroups[0].GroupId}" \
     --output table
   ```

4. If HIGH severity — check VPC Flow Logs for suspicious traffic from the affected instance:
   ```bash
   aws ec2 describe-flow-logs \
     --filter "Name=resource-id,Values=<VPC_ID>" \
     --query "FlowLogs[].{ID:FlowLogId,Status:FlowLogStatus,Destination:LogDestination}" \
     --output table
   ```

**Resolution:**

1. **LOW/MEDIUM findings (SEV-3):** Document the finding, review during next business day. Common findings like `Recon:EC2/PortProbeUnprotectedPort` on public subnets are expected noise in demo environments.

2. **HIGH findings (SEV-1):** Isolate the affected instance immediately:
   ```bash
   # Create an isolation security group that blocks all traffic
   ISOLATION_SG=$(aws ec2 create-security-group \
     --group-name "isolation-$(date +%s)" \
     --description "Incident isolation" \
     --vpc-id <VPC_ID> \
     --query "GroupId" --output text)

   # Replace the instance's security groups with the isolation group
   aws ec2 modify-instance-attribute \
     --instance-id <INSTANCE_ID> \
     --groups "$ISOLATION_SG"
   ```

3. Do NOT terminate the instance — it's evidence. The ASG will launch a clean replacement automatically.

**Verification:**
```bash
# Confirm the instance is isolated (only isolation SG attached)
aws ec2 describe-instances --instance-ids <INSTANCE_ID> \
  --query "Reservations[].Instances[].SecurityGroups" --output table

# Confirm ASG launched a replacement
aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?contains(AutoScalingGroupName,'vdm')].{InService:length(Instances[?LifecycleState=='InService'])}" \
  --output table
```

**Escalation:** Any HIGH severity finding must be reported to the team lead immediately, even at 3 AM. If the finding type contains `CryptoCurrency`, `Trojan`, or `Backdoor`, treat as SEV-1 and begin full incident response — the instance may be compromised.

---

### Incident: Budget Alert Threshold Breached

**Symptoms:** AWS Budget email notification. Monthly spend has exceeded a defined threshold (typically 80% or 100% of the $75 budget).

**Severity:** SEV-4 — No service impact, but requires investigation to prevent runaway costs.

**Diagnosis:**

1. Check current budget status:
   ```bash
   aws budgets describe-budgets --account-id "$(aws sts get-caller-identity --query Account --output text)" \
     --query "Budgets[?contains(BudgetName,'vdm')].{Name:BudgetName,Limit:BudgetLimit.Amount,Actual:CalculatedSpend.ActualSpend.Amount,Forecast:CalculatedSpend.ForecastedSpend.Amount}" \
     --output table
   ```

2. Identify which services are driving the cost:
   ```bash
   aws ce get-cost-and-usage \
     --time-period Start="$(date -u -d '30 days ago' +%Y-%m-%d)",End="$(date -u +%Y-%m-%d)" \
     --granularity MONTHLY \
     --metrics BlendedCost \
     --group-by Type=DIMENSION,Key=SERVICE \
     --query "ResultsByTime[].Groups[?Metrics.BlendedCost.Amount>'1'].{Service:Keys[0],Cost:Metrics.BlendedCost.Amount}" \
     --output table
   ```

3. Check for orphaned resources (common cost leaks):
   ```bash
   # Unused Elastic IPs (charged when not attached)
   aws ec2 describe-addresses \
     --query "Addresses[?AssociationId==null].{IP:PublicIp,AllocID:AllocationId}" \
     --output table

   # Orphaned EBS volumes (not attached to any instance)
   aws ec2 describe-volumes \
     --filters "Name=status,Values=available" \
     --query "Volumes[].{ID:VolumeId,Size:Size,Created:CreateTime}" \
     --output table

   # NAT Gateway (biggest single cost — ~$32/mo)
   aws ec2 describe-nat-gateways \
     --filter "Name=state,Values=available" \
     --query "NatGateways[].{ID:NatGatewayId,State:State,Created:CreateTime}" \
     --output table
   ```

4. Check if the ASG scaled up and stayed there:
   ```bash
   aws autoscaling describe-auto-scaling-groups \
     --query "AutoScalingGroups[?contains(AutoScalingGroupName,'vdm')].{Desired:DesiredCapacity,Min:MinSize,Max:MaxSize}" \
     --output table
   ```

**Resolution:**

1. Release orphaned EIPs: `aws ec2 release-address --allocation-id <ALLOC_ID>`
2. Delete orphaned EBS volumes: `aws ec2 delete-volume --volume-id <VOL_ID>`
3. If ASG is scaled to max without load → Check if the scaling policy is misfiring. Review the Target Tracking policy's metric.
4. If costs are expected (legitimate usage) → Adjust the budget threshold or acknowledge the alert.

**Verification:**
```bash
# Re-check cost forecast after cleanup
aws ce get-cost-forecast \
  --time-period Start="$(date -u +%Y-%m-%d)",End="$(date -u -d '+30 days' +%Y-%m-%d)" \
  --metric BLENDED_COST --granularity MONTHLY \
  --query "Total.Amount" --output text
```

**Escalation:** If spend exceeds 150% of budget and you cannot identify the source, escalate immediately. Consider running `terraform destroy` on non-critical resources to stop the bleed.

---

### Incident: CI/CD Pipeline Failure

**Symptoms:** GitHub Actions workflow shows red ✗ on the PR. Pipeline failed at one of the 4 stages: fmt, tfsec, init, or validate.

**Severity:** SEV-3 — No production impact (pipeline runs with `-backend=false` and no AWS credentials, see ADR-004). Blocks the PR from merging.

**Diagnosis:**

1. Open the failed GitHub Actions run. The stage name tells you exactly where it broke:

   | Failed Stage | What It Means |
   |-------------|---------------|
   | `terraform fmt` | Code formatting doesn't match canonical style |
   | `tfsec` | Security scanner found a misconfiguration |
   | `terraform init` | Provider download failed or version conflict |
   | `terraform validate` | HCL syntax error or invalid resource reference |

2. For each failure type:

   **`terraform fmt` failure:**
   ```bash
   # Find which files need formatting
   terraform fmt -check -recursive -diff
   # Auto-fix all files
   terraform fmt -recursive
   git add -A && git commit -m "style: terraform fmt"
   ```

   **`tfsec` failure:**
   ```bash
   # Run tfsec locally to see the exact findings
   tfsec . --format lovely
   # If tfsec is not installed, use Docker:
   docker run --rm -v "$(pwd):/src" aquasec/tfsec /src
   ```
   Review each finding. If it's a legitimate issue, fix it. If it's a false positive for this demo context (e.g., "S3 bucket should have access logging" on the state bucket), add an inline ignore comment:
   ```hcl
   #tfsec:ignore:aws-s3-enable-bucket-logging
   ```

   **`terraform init` failure:**
   ```bash
   # Clear the plugin cache and retry
   rm -rf .terraform .terraform.lock.hcl
   terraform init -backend=false
   ```
   If it still fails, check if the provider version constraint in `main.tf` matches available versions:
   ```bash
   terraform providers
   ```

   **`terraform validate` failure:**
   ```bash
   # Run validate locally with full error output
   terraform init -backend=false
   terraform validate
   ```
   The error message will include the exact file, line number, and description. Common causes: typo in resource attribute name, missing required argument, referencing a module output that doesn't exist.

**Resolution:**

1. Fix the issue locally using the commands above.
2. Push the fix. The pipeline will re-run automatically on the PR.

**Verification:**
```bash
# After pushing, confirm the pipeline passes
gh run list --limit 1 --json status,conclusion,name
# Or check: https://github.com/Victor-David-Medina/aws-terraform-portfolio/actions
```

**Escalation:** Pipeline failures don't affect production and can wait until business hours. Escalate only if `terraform init` fails consistently across all branches (may indicate a GitHub Actions or Terraform Registry outage — check https://status.hashicorp.com).

---

## Teardown Procedure

**Order matters.** Destroy the capstone infrastructure before the state bucket. See [backend-setup/README.md](../../backend-setup/README.md) for details.

```bash
# 1. Always backup state first
terraform state pull > backup.tfstate

# 2. Destroy capstone infrastructure
cd 05-capstone
terraform destroy

# 3. Destroy the state bucket last
cd backend-setup
terraform destroy
```
