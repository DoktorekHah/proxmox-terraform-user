# Proxmox Terraform Module - Makefile
# Terraform-only commands with Checkov security scanning

# Default values
TERRAFORM_CMD ?= terraform
TOFU_CMD ?= tofu
TFLINT_CMD ?= tflint
CHECKOV_CMD ?= checkov
PYTHON_CMD ?= python3
PIP_CMD ?= pip3
MODULE_DIR ?= .

# Colors for output (VSCode-inspired)make
RED := \033[1;31m
GREEN := \033[1;36m
YELLOW := \033[1;32m
BLUE := \033[1;34m
CYAN := \033[0;36m
MAGENTA := \033[1;35m
NC := \033[0m # No Color

.PHONY: help install checkov-install tflint-install tflint-check tflint-init \
        checkov-scan checkov-scan-json checkov-scan-sarif \
        terraform-init terraform-validate terraform-plan terraform-plan-out \
        terraform-apply terraform-apply-plan terraform-destroy terraform-format \
		tofu-init tofu-validate tofu-plan tofu-plan-out \
        tofu-apply tofu-apply-plan tofu-destroy tofu-format \
    	test-security test-lint clean clean-all dev-setup ci docs \
        test-terratest test-basic test-multiple test-ipv6 test-vlan test-plan test-validate \
        test-parallel terratest-deps terratest-fmt terratest-lint terratest-clean \
        terratest-init terratest-coverage

# Default target
help: ## Show this help message
	@echo "$(BLUE)Proxmox Terraform Module - Available Commands$(NC)"
	@echo ""
	@echo "$(YELLOW)Installation:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(install|checkov-install|tflint-install)"
	@echo ""
	@echo "$(YELLOW)Security:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(checkov)"
	@echo ""
	@echo "$(YELLOW)Linting:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(tflint)"
	@echo ""
	@echo "$(YELLOW)Terraform Commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(terraform)"
	@echo ""
	@echo "$(YELLOW)OpenTofu Commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(tofu)"
	@echo ""
	@echo "$(YELLOW)Testing:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep test
	@echo ""
	@echo "$(YELLOW)Terratest (Go Tests):$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep terratest
	@echo ""
	@echo "$(YELLOW)Utilities:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(clean|help|dev-setup|ci|docs)"

# Installation targets
install: checkov-install-venv tflint-install ## Install all dependencies
	@echo "$(GREEN)✓ All dependencies installed$(NC)"

checkov-install-pipx: ## Install Checkov security scanner
	@echo "$(BLUE)Installing Checkov...$(NC)"
	@if command -v pipx &> /dev/null; then \
		echo "$(YELLOW)Using pipx to install Checkov...$(NC)"; \
		pipx install checkov; \
	else \
		echo "$(YELLOW)Trying to install with --user flag...$(NC)"; \
		$(PIP_CMD) install --user -r requirements.txt; \
	fi
	@echo "$(GREEN)✓ Checkov installation completed$(NC)"

checkov-install-venv:
	@echo "$(BLUE)Installing Checkov...$(NC)"
	@if command -v python3.12 -m venv &> /dev/null; then \
		echo "$(YELLOW)Creating virtual environment and installing Checkov...$(NC)"; \
		python3.12 -m venv .venv; \
		source .venv/bin/activate && pip install -r requirements.txt; \
		echo "$(YELLOW)Virtual environment created at .venv. Activate with: source .venv/bin/activate$(NC)"; \
	else \
		echo "$(YELLOW)Trying to install with --user flag...$(NC)"; \
		$(PIP_CMD) install --user -r requirements.txt; \
	fi
	@echo "$(GREEN)✓ Checkov installation completed$(NC)"

tflint-install: ## Install TFLint linter
	@echo "$(BLUE)Installing TFLint...$(NC)"
	@if command -v tflint &> /dev/null; then \
		echo "$(YELLOW)TFLint is already installed$(NC)"; \
		tflint --version; \
	elif [[ "$$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then \
		echo "$(YELLOW)Installing TFLint via Homebrew...$(NC)"; \
		brew install tflint; \
	elif [[ "$$OSTYPE" == "linux-gnu"* ]]; then \
		echo "$(YELLOW)Installing TFLint via curl...$(NC)"; \
		curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash; \
	else \
		echo "$(YELLOW)Please install TFLint manually: https://github.com/terraform-linters/tflint$(NC)"; \
	fi
	@echo "$(GREEN)✓ TFLint installation completed$(NC)"

# Security scanning targets
checkov-scan: ## Run Checkov security scan on module
	@echo "$(BLUE)Running Checkov security scan...$(NC)"
	@if [ -f .venv/bin/checkov ]; then \
		.venv/bin/checkov -d . --config-file .checkov.yml; \
	elif command -v checkov &> /dev/null; then \
		checkov -d . --config-file .checkov.yml; \
	else \
		echo "$(RED)Checkov not found. Please run 'make checkov-install' first$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ Checkov scan completed$(NC)"

checkov-scan-plan: ## Run Checkov scan tfplan and output JSON results
	@echo "$(BLUE)Running Checkov scan with JSON output...$(NC)"
	@if [ -f .venv/bin/checkov ]; then \
		.venv/bin/checkov -d . --config-file .checkov.yml --output json --output-file-path checkov-results.json -f tfplan.json; \
	elif command -v checkov &> /dev/null; then \
		checkov -d . --config-file .checkov.yml --output json --output-file-path checkov-results.json -f tfplan.json; \
	else \
		echo "$(RED)Checkov not found. Please run 'make checkov-install' first$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ Checkov JSON results saved to checkov-results.json$(NC)"

checkov-scan-sarif: ## Run Checkov scan tfplan and output SARIF results
	@echo "$(BLUE)Running Checkov scan with SARIF output...$(NC)"
	@if [ -f .venv/bin/checkov ]; then \
		.venv/bin/checkov -d . --config-file .checkov.yml --output sarif --output-file-path checkov-results.sarif -f tfplan.json;; \
	elif command -v checkov &> /dev/null; then \
		checkov -d . --config-file .checkov.yml --output sarif --output-file-path checkov-results.sarif -f tfplan.json; \
	else \
		echo "$(RED)Checkov not found. Please run 'make checkov-install' first$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ Checkov SARIF results saved to checkov-results.sarif$(NC)"

# TFLint targets
tflint-init: ## Initialize TFLint plugins
	@echo "$(BLUE)Initializing TFLint plugins...$(NC)"
	@if command -v $(TFLINT_CMD) &> /dev/null; then \
		$(TFLINT_CMD) --init; \
	else \
		echo "$(RED)TFLint not found. Please run 'make tflint-install' first$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ TFLint plugins initialized$(NC)"

tflint-check: ## Run TFLint to check Terraform code
	@echo "$(BLUE)Running TFLint check...$(NC)"
	@if command -v $(TFLINT_CMD) &> /dev/null; then \
		$(TFLINT_CMD) --config=.tflint.hcl; \
	else \
		echo "$(RED)TFLint not found. Please run 'make tflint-install' first$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ TFLint check completed$(NC)"

# Terraform targets
terraform-init: ## Initialize Terraform
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	$(TERRAFORM_CMD) init
	@echo "$(GREEN)✓ Terraform initialized$(NC)"

terraform-validate: ## Validate Terraform configuration
	@echo "$(BLUE)Validating Terraform configuration...$(NC)"
	$(TERRAFORM_CMD) validate
	@echo "$(GREEN)✓ Terraform configuration is valid$(NC)"

terraform-plan: ## Create Terraform execution plan
	@echo "$(BLUE)Creating Terraform execution plan...$(NC)"
	$(TERRAFORM_CMD) plan
	@echo "$(GREEN)✓ Terraform plan completed$(NC)"

terraform-plan-out: ## Create Terraform plan and save to file
	@echo "$(BLUE)Creating Terraform execution plan and saving to file...$(NC)"
	$(TERRAFORM_CMD) plan -out=tfplan.binary
	@echo "$(GREEN)✓ Terraform plan saved to tfplan$(NC)"

terraform-apply: ## Apply Terraform configuration
	@echo "$(BLUE)Applying Terraform configuration...$(NC)"
	$(TERRAFORM_CMD) apply -auto-approve
	@echo "$(GREEN)✓ Terraform apply completed$(NC)"

terraform-destroy: ## Destroy Terraform-managed infrastructure
	@echo "$(RED)Destroying Terraform-managed infrastructure...$(NC)"
	$(TERRAFORM_CMD) destroy -auto-approve
	@echo "$(GREEN)✓ Terraform destroy completed$(NC)"

terraform-format: ## Format Terraform files
	@echo "$(BLUE)Formatting Terraform files...$(NC)"
	$(TERRAFORM_CMD) fmt -recursive
	@echo "$(GREEN)✓ Terraform files formatted$(NC)"

terraform-show-json: ## Apply OpenTofu using saved plan
	@echo "$(BLUE)Applying OpenTofu using saved plan...$(NC)"
	$(TOFU_CMD) show -json tfplan.binary | jq > tfplan.json 
	@echo "$(GREEN)✓ OpenTofu apply from plan completed$(NC)"

# OpenTofu targets
tofu-init: ## Initialize OpenTofu
	@echo "$(BLUE)Initializing OpenTofu...$(NC)"
	$(TOFU_CMD) init
	@echo "$(GREEN)✓ OpenTofu initialized$(NC)"

tofu-validate: ## Validate OpenTofu configuration
	@echo "$(BLUE)Validating OpenTofu configuration...$(NC)"
	$(TOFU_CMD) validate
	@echo "$(GREEN)✓ OpenTofu configuration is valid$(NC)"

tofu-plan: ## Create OpenTofu execution plan
	@echo "$(BLUE)Creating OpenTofu execution plan...$(NC)"
	$(TOFU_CMD) plan
	@echo "$(GREEN)✓ OpenTofu plan completed$(NC)"

tofu-plan-out: ## Create OpenTofu plan and save to file
	@echo "$(BLUE)Creating OpenTofu execution plan and saving to file...$(NC)"
	$(TOFU_CMD) plan -out=tofuplan.binary
	@echo "$(GREEN)✓ OpenTofu plan saved to tofuplan$(NC)"

tofu-apply: ## Apply OpenTofu configuration
	@echo "$(BLUE)Applying OpenTofu configuration...$(NC)"
	$(TOFU_CMD) apply -auto-approve
	@echo "$(GREEN)✓ OpenTofu apply completed$(NC)"

tofu-destroy: ## Destroy OpenTofu-managed infrastructure
	@echo "$(RED)Destroying OpenTofu-managed infrastructure...$(NC)"
	$(TOFU_CMD) destroy -auto-approve
	@echo "$(GREEN)✓ OpenTofu destroy completed$(NC)"

tofu-format: ## Format OpenTofu files
	@echo "$(BLUE)Formatting OpenTofu files...$(NC)"
	$(TOFU_CMD) fmt -recursive
	@echo "$(GREEN)✓ OpenTofu files formatted$(NC)"

tofu-show-json: ## Apply OpenTofu using saved plan
	@echo "$(BLUE)Applying OpenTofu using saved plan...$(NC)"
	$(TOFU_CMD) show -json tfplan.binary | jq > tfplan.json 
	@echo "$(GREEN)✓ OpenTofu apply from plan completed$(NC)"

# Testing targets
test-terraform-security: terraform-plan-out terraform-show-json checkov-scan-json-plan  ## Run security tests only
	@echo "$(GREEN)✓ Security tests completed$(NC)"

test-tofu-security: tofu-plan-out tofu-show-json checkov-scan-json-plan ## Run security tests only
	@echo "$(GREEN)✓ Security tests completed$(NC)"

# Terratest (Go) targets
test-terratest: ## Run all terratest tests
	@echo "$(BLUE)Running all terratest tests...$(NC)"
	cd terratest && go test -v -timeout 30m
	@echo "$(GREEN)✓ Terratest tests completed$(NC)"

test-basic: ## Run basic user test
	@echo "$(BLUE)Running basic user test...$(NC)"
	cd terratest && go test -v -timeout 30m -run TestProxmoxUserBasic
	@echo "$(GREEN)✓ Basic test completed$(NC)"

test-multiple: ## Run multiple users test
	@echo "$(BLUE)Running multiple users test...$(NC)"
	cd terratest && go test -v -timeout 30m -run TestProxmoxUserMultiple
	@echo "$(GREEN)✓ Multiple users test completed$(NC)"

test-plan: ## Run plan-only test
	@echo "$(BLUE)Running plan-only test...$(NC)"
	cd terratest && go test -v -timeout 30m -run TestProxmoxUserPlanOnly
	@echo "$(GREEN)✓ Plan-only test completed$(NC)"

test-validate: ## Run validation test
	@echo "$(BLUE)Running validation test...$(NC)"
	cd terratest && go test -v -timeout 30m -run TestProxmoxUserValidation
	@echo "$(GREEN)✓ Validation test completed$(NC)"

terratest-deps: ## Install terratest dependencies
	@echo "$(BLUE)Installing terratest dependencies...$(NC)"
	cd terratest && go mod download && go mod tidy
	@echo "$(GREEN)✓ Terratest dependencies installed$(NC)"

terratest-fmt: ## Format terratest Go code
	@echo "$(BLUE)Formatting terratest Go code...$(NC)"
	cd terratest && go fmt ./...
	@echo "$(GREEN)✓ Terratest code formatted$(NC)"

terratest-lint: ## Lint terratest Go code
	@echo "$(BLUE)Linting terratest Go code...$(NC)"
	cd terratest && golangci-lint run
	@echo "$(GREEN)✓ Terratest code linted$(NC)"

terratest-clean: ## Clean up terratest artifacts
	@echo "$(BLUE)Cleaning up terratest artifacts...$(NC)"
	cd terratest && rm -f *.test *.out *.log coverage.out coverage.html plan
	find examples -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find examples -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	find examples -type f -name "*.tfstate*" -delete 2>/dev/null || true
	find examples -type f -name "crash.log" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Terratest cleanup completed$(NC)"

terratest-init: ## Initialize terratest Go module
	@echo "$(BLUE)Initializing terratest Go module...$(NC)"
	cd terratest && go mod init github.com/proxmox/modules/proxmox-terraform-user/terratest || true
	cd terratest && go mod tidy
	@echo "$(GREEN)✓ Terratest initialized$(NC)"

terratest-coverage: ## Run terratest with coverage report
	@echo "$(BLUE)Running terratest with coverage...$(NC)"
	cd terratest && go test -v -timeout 30m -coverprofile=coverage.out
	cd terratest && go tool cover -html=coverage.out -o coverage.html
	@echo "$(CYAN)Coverage report generated: terratest/coverage.html$(NC)"
	@echo "$(GREEN)✓ Coverage report completed$(NC)"

# Utility targets
clean: ## Clean up generated files
	@echo "$(BLUE)Cleaning up generated files...$(NC)"
	rm -rf checkov-results.json results.sarif
	rm -f tfplan
	rm -rf .terraform .terraform.lock.hcl
	@echo "$(GREEN)✓ Cleanup completed$(NC)"

clean-all: clean ## Clean up all files including Terraform state
	@echo "$(BLUE)Cleaning up all files including state...$(NC)"
	clean
	rm -f terraform.tfstate* terraform.tfstate.backup
	terratest-clean
	@echo "$(GREEN)✓ Complete cleanup finished$(NC)"

# CI/CD targets
ci-terraform: terraform-init terraform-validate tflint-init tflint-check test-terraform-security ## CI pipeline for Terraform
	@echo "$(GREEN)✓ CI Terraform pipeline completed$(NC)"

ci-terraform-apply: terraform-init terraform-validate tflint-init tflint-check test-terraform-security terraform-apply ## CI pipeline for Terraform
	@echo "$(GREEN)✓ CI Terraform pipeline completed$(NC)"

ci-tofu: tofu-init tofu-validate tflint-init tflint-check test-tofu-security ## CI pipeline for OpenTofu
	@echo "$(GREEN)✓ CI OpenTofu pipeline completed$(NC)"

ci-tofu-apply: tofu-init tofu-validate tflint-init tflint-check test-tofu-security tofu-apply ## CI pipeline for OpenTofu
	@echo "$(GREEN)✓ CI OpenTofu pipeline completed$(NC)"

# Documentation
docs: ## Show module documentation
	@echo "$(BLUE)Proxmox Terraform User Module$(NC)"
	@echo ""
	@echo "This module manages Proxmox users using Terraform or OpenTofu"
	@echo ""
	@echo "Quick Start:"
	@echo "  1. make install             - Install dependencies"
	@echo "  2. make tflint-init         - Initialize TFLint"
	@echo "  3. make terraform-init      - Initialize Terraform"
	@echo "  4. make terraform-plan      - Preview changes"
	@echo "  5. make terraform-apply     - Apply changes"
	@echo "  6. make tofu-init           - Initialize OpenTofu"
	@echo "  7. make tofu-plan           - Preview changes"
	@echo "  8. make tofu-apply          - Apply changes"
	@echo ""
	@echo "For all commands: make help"
	@echo "$(GREEN)✓ Documentation displayed$(NC)"

