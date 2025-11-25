.PHONY: deploy destroy e2e-test clean lint format fmt-diff lint-ci security tflint tfsec checkov install-tools

# Default AWS profile
AWS_PROFILE ?= default
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

install-tools:
	@echo "🔧 Installing security and quality tools..."
	@echo "Installing TFLint..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install tflint; \
	else \
		curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash; \
	fi
	@echo "Installing TFSec..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install tfsec; \
	else \
		curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash; \
	fi
	@echo "Installing Checkov..."
	@if command -v pip3 >/dev/null 2>&1; then \
		pip3 install checkov; \
	elif command -v pip >/dev/null 2>&1; then \
		pip install checkov; \
	else \
		echo "❌ Python pip not found. Please install Python and pip first."; \
		exit 1; \
	fi
	@echo "✅ All tools installed successfully!"

tflint:
	@echo "🔍 Running TFLint..."
	@tflint --init
	@tflint --config .tflint.hcl
	@echo "✅ TFLint check completed"

tfsec:
	@echo "🔒 Running TFSec security scan..."
	@tfsec . --config-file .tfsec.yml
	@echo "✅ TFSec scan completed"

checkov:
	@echo "🛡️ Running Checkov compliance scan..."
	@checkov -d . --config-file .checkov.yml --compact
	@echo "✅ Checkov scan completed"

security: tfsec checkov
	@echo "🔐 Security scans completed!"

help:
	@echo "Available targets:"
	@echo ""
	@echo "🚀 Deployment:"
	@echo "  deploy       - Deploy all RTB Fabric resources"
	@echo "  destroy      - Destroy all RTB Fabric resources"
	@echo "  e2e-test     - Run full end-to-end test (deploy + destroy)"
	@echo ""
	@echo "🔍 Code Quality:"
	@echo "  lint         - Run code quality checks (format + validate)"
	@echo "  format       - Format all Terraform code"
	@echo "  fmt-diff     - Show what formatting changes are needed"
	@echo "  tflint       - Run TFLint for Terraform best practices"
	@echo ""
	@echo "🔒 Security:"
	@echo "  security     - Run all security scans (tfsec + checkov)"
	@echo "  tfsec        - Run TFSec security scanner"
	@echo "  checkov      - Run Checkov compliance scanner"
	@echo ""
	@echo "🔧 Setup:"
	@echo "  install-tools - Install all security and quality tools"
	@echo "  clean        - Clean Terraform state and cache files"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  AWS_PROFILE - AWS profile to use (default: shapirov+2-Admin)"