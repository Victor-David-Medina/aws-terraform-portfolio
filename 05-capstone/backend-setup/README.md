# Backend Bootstrap — Remote State Setup

This directory creates the S3 bucket that stores Terraform state for the capstone project. It exists as a separate root module because of the **chicken-and-egg problem**: the capstone's `backend "s3"` block needs the bucket to already exist before `terraform init` can connect to it.

> For the full design rationale, see [ADR-005: Remote State with S3 Backend](../docs/adr/ADR-005-remote-state.md).

## What This Creates

| Resource | Purpose |
|----------|---------|
| `aws_s3_bucket` | Stores `terraform.tfstate` for the capstone |
| `aws_s3_bucket_versioning` | Protects against accidental state overwrites |
| `aws_s3_bucket_server_side_encryption_configuration` | AES-256 encryption at rest |
| `aws_s3_bucket_public_access_block` | Blocks all public access to state files |

## Why No DynamoDB Table?

Terraform 1.10 introduced native S3-based state locking via `use_lockfile = true`. This writes a `.tflock` file to the same S3 bucket instead of requiring a separate DynamoDB table. The result is fewer resources to manage, no DynamoDB costs, and simpler IAM permissions. See ADR-005 for the alternatives we evaluated.

## Bootstrap Steps

**Prerequisites:** AWS CLI configured with credentials that can create S3 buckets, and Terraform ≥ 1.10 installed.

### 1. Create the state bucket

```bash
cd 05-capstone/backend-setup
terraform init
terraform apply
```

Terraform will show the bucket name and ARN. Confirm with `yes`.

### 2. Enable the backend in the capstone

Open `05-capstone/main.tf` and uncomment the backend block:

```hcl
backend "s3" {
  bucket       = "vdm-terraform-state"
  key          = "capstone/terraform.tfstate"
  region       = "us-east-1"
  use_lockfile = true
}
```

### 3. Migrate local state to S3

```bash
cd ..   # back to 05-capstone/
terraform init -migrate-state
```

Terraform will ask to copy existing local state to the S3 backend. Confirm with `yes`. After migration, the local `terraform.tfstate` file can be safely deleted (Terraform keeps it as a backup at `terraform.tfstate.backup`).

### 4. Verify

```bash
terraform plan
```

If the plan runs successfully and shows "No changes," the backend is working. You can also confirm the state file exists:

```bash
aws s3 ls s3://vdm-terraform-state/capstone/
```

## Teardown Order

When destroying the project, destroy the capstone infrastructure **before** the state bucket:

```bash
cd 05-capstone
terraform destroy          # destroys VPC, ASG, etc.

cd backend-setup
terraform destroy          # destroys the S3 bucket last
```

Destroying the bucket first would orphan the capstone's state file and make `terraform destroy` unable to track what needs cleanup.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Error: Failed to get existing workspaces` | Backend block uncommented before bucket exists | Run `backend-setup/terraform apply` first |
| `Error: state lock` | Another `terraform apply` is running | Wait for it to finish, or check for stale `.tflock` in S3 |
| `BucketAlreadyOwnedByYou` | Bucket was already created | Safe to ignore — `terraform apply` will show no changes |
