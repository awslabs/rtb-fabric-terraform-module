.PHONY: deploy destroy e2e-test clean lint format fmt-diff lint-ci

# Default AWS profile
AWS_PROFILE ?= shapirov+2-Admin
E2E_DIR = examples/e2e-test

# Export AWS profile for all commands
export AWS_PROFILE

deploy:
	@echo "🚀 Deploying RTB Fabric E2E test..."
	cd $(E2E_DIR) && terraform init
	cd $(E2E_DIR) && terraform plan
	cd $(E2E_DIR) && terraform apply -auto-approve
	@echo "✅ Deployment complete!"
	@echo "📊 Resource summary:"
	cd $(E2E_DIR) && terraform output

destroy:
	@echo "🧹 Destroying RTB Fabric E2E test resources..."
	cd $(E2E_DIR) && terraform destroy -auto-approve
	@echo "✅ Cleanup complete!"

e2e-test: deploy
	@echo "⏳ Waiting 30 seconds for resources to stabilize..."
	sleep 30
	@echo "🧪 E2E test completed successfully!"
	@echo "🧹 Starting cleanup..."
	$(MAKE) destroy

clean:
	@echo "🧹 Cleaning up Terraform state and cache..."
	cd $(E2E_DIR) && rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
	@echo "✅ Clean complete!"

lint:
	@echo "🔍 Running Terraform code quality checks..."
	@if ! terraform fmt -check -recursive; then \
		echo "❌ Formatting issues found. Here are the changes needed:"; \
		terraform fmt -diff -recursive; \
		echo "Run 'make format' to fix these issues."; \
		exit 1; \
	fi
	@echo "✅ Formatting check passed"
	@echo "🔧 Initializing Terraform..."
	@terraform init -backend=false
	@terraform validate
	@echo "✅ Validation check passed"

format:
	@echo "🎨 Formatting Terraform code..."
	@terraform fmt -recursive
	@echo "✅ Formatting complete"

fmt-diff:
	@echo "🔍 Showing formatting changes needed..."
	@terraform fmt -diff -recursive

lint-ci:
	@echo "🔍 Running Terraform code quality checks (CI mode)..."
	@if ! terraform fmt -check -recursive; then \
		echo "❌ Formatting issues found. Here are the changes needed:"; \
		terraform fmt -diff -recursive; \
		echo "Run 'make format' to fix these issues."; \
		exit 1; \
	fi
	@echo "✅ Formatting check passed"
	@echo "ℹ️ Skipping validation in CI (no AWS credentials needed)"

help:
	@echo "Available targets:"
	@echo "  deploy    - Deploy all RTB Fabric resources"
	@echo "  destroy   - Destroy all RTB Fabric resources"
	@echo "  e2e-test  - Run full end-to-end test (deploy + destroy)"
	@echo "  lint      - Run code quality checks (format + validate)"
	@echo "  format    - Format all Terraform code"
	@echo "  fmt-diff  - Show what formatting changes are needed"
	@echo "  clean     - Clean Terraform state and cache files"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  AWS_PROFILE - AWS profile to use (default: shapirov+2-Admin)"