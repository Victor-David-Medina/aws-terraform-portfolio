# Backend Setup: S3 Remote State

This directory bootstraps the S3 bucket that stores Terraform state for the capstone project.

## The Bootstrap Problem

Terraform needs the S3 bucket to exist *before* it can store state there. But you cannot create the bucket with the same Terraform configuration that uses it as a backend. This directory solves that: create the bucket first here, then reference it from the capstone's backend block.

## What Gets Created

| Resource | Purpose |
|----------|---------|
| `aws_s3_bucket` | State file storage with a random hex suffix for uniqueness |
| `aws_s3_bucket_versioning` | Protects against accidental state overwrites |
| `aws_s3_bucket_public_access_block` | Blocks all public access (all 4 settings) |
| `random_id` | Generates a unique bucket name suffix to avoid collisions |

## Deploy

```bash
cd backend-setup
terraform init
terraform apply
```

After apply, copy the `bucket_name` output value. You will paste it into the capstone backend configuration.

## Wire It to the Capstone

1. Open `05-capstone/providers.tf`
2. Uncomment the `backend "s3"` block
3. Replace the bucket name with the value from the output above
4. Run `terraform init -migrate-state` from `05-capstone/`

## Cleanup

Destroy the capstone infrastructure first, then the state bucket:

```bash
cd 05-capstone && terraform destroy
cd ../backend-setup && terraform destroy
```

If the bucket contains state files, empty it before destroying:

```bash
aws s3 rm s3://BUCKET_NAME --recursive
terraform destroy
```

## Troubleshooting

**"BucketAlreadyExists" error**: S3 bucket names are globally unique. The `random_id` suffix handles this, but if you previously created a bucket with the same prefix, destroy the old one first.

**"AccessDenied" on init**: Your AWS CLI credentials need `s3:GetObject`, `s3:PutObject`, and `s3:ListBucket` on the state bucket. Verify with `aws sts get-caller-identity`.
