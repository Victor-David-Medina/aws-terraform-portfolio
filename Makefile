.PHONY: fmt validate security init plan

# Format all Terraform files
fmt:
	terraform fmt -recursive

# Check formatting without modifying files
fmt-check:
	terraform fmt -check -recursive

# Validate all phases
validate:
	@for dir in 01-s3-bucket 02-vpc 03-modules 04-advanced-hcl 05-capstone; do \
		echo "=== $$dir ===" && \
		cd $$dir && terraform init -backend=false -input=false > /dev/null 2>&1 && \
		terraform validate && cd ..; \
	done

# Run tfsec security scan
security:
	tfsec .

# Initialize the capstone project
init:
	cd 05-capstone && terraform init -backend=false

# Plan the capstone project (requires AWS credentials)
plan:
	cd 05-capstone && terraform plan

# Run all CI checks locally
ci: fmt-check validate security
	@echo "All checks passed."
