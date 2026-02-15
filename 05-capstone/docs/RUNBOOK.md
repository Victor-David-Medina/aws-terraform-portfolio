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

## Troubleshooting

### EC2 Instances Cannot Reach Internet

1. Verify NAT Gateway status in AWS Console

2. Check route table associations for private subnets

3. Confirm security group allows outbound traffic

### State Lock Timeout

```bash

# Check for stale locks

aws dynamodb scan --table-name terraform-state-lock

# Force unlock if needed (use with caution)

terraform force-unlock LOCK_ID

```

## Teardown Procedure

```bash

# Always backup state first

terraform state pull > backup.tfstate

terraform destroy

```

