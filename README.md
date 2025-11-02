# Proxmox User Terraform Module

A comprehensive Terraform/OpenTofu module for managing Proxmox users with integrated security scanning (Checkov) and code linting (TFLint). This module supports both Terraform and OpenTofu through a unified Makefile.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.6.0-623CE4)](https://www.terraform.io/)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-%3E%3D1.0-FFDA18)](https://opentofu.org/)
[![Go](https://img.shields.io/badge/Go-%3E%3D1.19-00ADD8)](https://golang.org/)
[![Python](https://img.shields.io/badge/Python-%3E%3D3.8-3776AB)](https://www.python.org/)
[![Checkov](https://img.shields.io/badge/Checkov-Security-6B4FBB)](https://www.checkov.io/)
[![TFLint](https://img.shields.io/badge/TFLint-Linting-5C4EE5)](https://github.com/terraform-linters/tflint)
[![Terratest](https://img.shields.io/badge/Terratest-Testing-00ADD8)](https://terratest.gruntwork.io/)

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Usage](#-usage)
- [Makefile Commands](#-makefile-commands)
- [Security & Linting](#-security--linting)
- [Testing](#-testing)
- [Module Reference](#-module-reference)
- [Development](#-development)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### Core Capabilities
- **Dual Tool Support**: Works with both Terraform and OpenTofu
- **User Management**: Complete user lifecycle management on Proxmox VE
- **ACL Configuration**: Flexible access control list management
- **Password Management**: Secure password handling with sensitive variables
- **Role-Based Access**: Integration with Proxmox role system

### Security & Quality
- **Security Scanning**: Integrated Checkov for IaC security analysis
- **Code Linting**: TFLint for Terraform/OpenTofu code quality
- **CI/CD Ready**: Pre-configured pipelines for both Terraform and OpenTofu
- **Best Practices**: Follows Terraform/OpenTofu module best practices

### Advanced Features
- **Account Control**: Enable/disable user accounts
- **ACL Propagation**: Control permission inheritance
- **Custom Comments**: User documentation and tracking
- **Sensitive Data Handling**: Secure password and account state management

## 🔧 Prerequisites

### Required Tools
- **Terraform** >= 1.6.0 OR **OpenTofu** >= 1.0
- **Python** >= 3.8 (for Checkov security scanning)
- **TFLint** (automatically installed via Makefile)
- **Proxmox VE** cluster with API access

### Optional Tools
- **Go** >= 1.19 (for Terratest integration tests)
- **Terratest** - Go library for automated infrastructure testing
- **pipx** or **pip3** (for Checkov installation)

### Provider Requirements
- `bpg/proxmox` >= 0.63.3

## 🚀 Quick Start

### 1. Install Dependencies

```bash
# Install all dependencies (Checkov + TFLint)
make install

# Or install individually
make checkov-install
make tflint-install
```

### 2. Initialize TFLint

```bash
# Initialize TFLint plugins (required once)
make tflint-init
```

### 3. Choose Your Tool

#### Using Terraform:
```bash
# Initialize Terraform
make terraform-init

# Validate configuration
make terraform-validate

# Preview changes
make terraform-plan

# Apply changes
make terraform-apply
```

#### Using OpenTofu:
```bash
# Initialize OpenTofu
make tofu-init

# Validate configuration
make tofu-validate

# Preview changes
make tofu-plan

# Apply changes
make tofu-apply
```

### 4. Run Security & Quality Checks

```bash
# Run CI pipeline (recommended)
make ci-terraform    # For Terraform
make ci-tofu         # For OpenTofu

# Or run individually
make checkov-scan    # Security scan
make tflint-check    # Code linting
```

## 💻 Usage

### Basic User Configuration

```hcl
module "proxmox_user" {
  source = "github.com/your-org/proxmox-terraform-user"

  # User Configuration
  user_id = "admin@pve"
  secret  = "secure-password-here"
  
  # ACL Configuration
  role_id   = "Administrator"
  path      = "/"
  propagate = true
  
  # Account Settings
  enabled_account = true
  comment         = "Managed by Terraform"
}
```

### User with Limited Permissions

```hcl
module "readonly_user" {
  source = "github.com/your-org/proxmox-terraform-user"

  user_id = "readonly@pve"
  secret  = var.readonly_password
  
  # Read-only access to specific path
  role_id   = "PVEAuditor"
  path      = "/vms/production"
  propagate = true
  
  enabled_account = true
  comment         = "Read-only user for monitoring"
}
```

### API User for Automation

```hcl
module "automation_user" {
  source = "github.com/your-org/proxmox-terraform-user"

  user_id = "terraform@pve"
  secret  = var.automation_password
  
  # VM management permissions
  role_id   = "PVEVMAdmin"
  path      = "/vms"
  propagate = true
  
  enabled_account = true
  comment         = "Automation user for Terraform"
}
```

### Multiple Users with Different Roles

```hcl
module "admin_user" {
  source = "github.com/your-org/proxmox-terraform-user"

  user_id         = "admin@pve"
  secret          = var.admin_password
  role_id         = "Administrator"
  path            = "/"
  propagate       = true
  enabled_account = true
  comment         = "Main administrator account"
}

module "backup_user" {
  source = "github.com/your-org/proxmox-terraform-user"

  user_id         = "backup@pve"
  secret          = var.backup_password
  role_id         = "PVEDatastoreAdmin"
  path            = "/storage"
  propagate       = true
  enabled_account = true
  comment         = "Backup operations user"
}

module "developer_user" {
  source = "github.com/your-org/proxmox-terraform-user"

  user_id         = "developer@pve"
  secret          = var.developer_password
  role_id         = "PVEVMUser"
  path            = "/vms/development"
  propagate       = false
  enabled_account = true
  comment         = "Developer with limited VM access"
}
```

### Disabled User Account

```hcl
module "disabled_user" {
  source = "github.com/your-org/proxmox-terraform-user"

  user_id         = "olduser@pve"
  secret          = "placeholder-password"
  role_id         = "PVEAuditor"
  path            = "/"
  propagate       = true
  enabled_account = false
  comment         = "Disabled user account"
}
```

## 📋 Makefile Commands

### Installation & Setup

```bash
make install              # Install all dependencies (Checkov + TFLint)
make checkov-install      # Install Checkov security scanner
make tflint-install       # Install TFLint linter
make tflint-init          # Initialize TFLint plugins
make dev-setup            # Set up complete development environment
```

### Security Scanning (Checkov)

```bash
make checkov-scan         # Run Checkov security scan
make checkov-scan-json    # Run scan with JSON output
make checkov-scan-sarif   # Run scan with SARIF output (CI/CD)
make test-security        # Run security tests only
```

### Code Linting (TFLint)

```bash
make tflint-init          # Initialize TFLint plugins
make tflint-check         # Run TFLint code quality checks
make test-lint            # Run linting tests only
```

### Terraform Commands

```bash
make terraform-init       # Initialize Terraform
make terraform-validate   # Validate Terraform configuration
make terraform-plan       # Create execution plan
make terraform-plan-out   # Create and save execution plan
make terraform-apply      # Apply configuration
make terraform-apply-plan # Apply saved plan
make terraform-destroy    # Destroy infrastructure
make terraform-format     # Format Terraform files
```

### OpenTofu Commands

```bash
make tofu-init            # Initialize OpenTofu
make tofu-validate        # Validate OpenTofu configuration
make tofu-plan            # Create execution plan
make tofu-plan-out        # Create and save execution plan
make tofu-apply           # Apply configuration
make tofu-apply-plan      # Apply saved plan
make tofu-destroy         # Destroy infrastructure
make tofu-format          # Format OpenTofu files
```

### Testing Commands

```bash
make test-terraform-security  # Run Terraform security tests
make test-tofu-security       # Run OpenTofu security tests
make test-terratest           # Run all Terratest tests
make test-basic               # Run basic user test
make test-multiple            # Run multiple users test
make test-plan                # Run plan-only test
make test-validate            # Run validation test
```

### CI/CD Commands

```bash
make ci-terraform         # CI pipeline for Terraform (init + validate + lint + security)
make ci-terraform-apply   # CI pipeline for Terraform with apply
make ci-tofu              # CI pipeline for OpenTofu (init + validate + lint + security)
make ci-tofu-apply        # CI pipeline for OpenTofu with apply
```

### Utility Commands

```bash
make clean                # Clean up generated files
make clean-all            # Clean up all files including state
make help                 # Show all available commands
make docs                 # Display module documentation
```

## 🔒 Security & Linting

### Checkov Security Scanning

This module includes integrated security scanning using [Checkov](https://www.checkov.io/) to ensure your infrastructure code follows security best practices.

**Key Features:**
- 🛡️ Security misconfiguration detection
- ✅ Compliance framework validation
- 📊 Multiple output formats (CLI, JSON, SARIF)
- 🔌 CI/CD integration ready
- 📝 Custom policy support

**Configuration:** `.checkov.yml`

```yaml
framework:
  - terraform

output:
  - cli
  - json
  - sarif

skip-download: true
```

**Usage:**
```bash
# Run security scan
make checkov-scan

# Generate JSON report
make checkov-scan-json

# Generate SARIF report for CI/CD
make checkov-scan-sarif
```

### TFLint Code Quality

TFLint checks your Terraform/OpenTofu code for errors, deprecated syntax, and best practices.

**Key Features:**
- 🔍 Syntax and logic error detection
- 📏 Best practice enforcement
- 🎯 Provider-specific rule sets
- 🔄 Naming convention validation
- 📚 Module version checking

**Configuration:** `.tflint.hcl`

```hcl
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_naming_convention" {
  enabled = true
}
```

**Usage:**
```bash
# Initialize TFLint (once)
make tflint-init

# Run code quality checks
make tflint-check
```

### Security Best Practices

1. **Always scan before deploy:**
   ```bash
   make checkov-scan && make tflint-check
   ```

2. **Review scan results:**
   - Address all **Failed** checks
   - Understand **Skipped** checks
   - Document exceptions

3. **Integrate into CI/CD:**
   ```bash
   make ci-terraform  # Runs security + linting + validation for Terraform
   make ci-tofu       # Runs security + linting + validation for OpenTofu
   ```

## 🧪 Testing

### Quick Test Workflows

```bash
# Run complete CI pipeline
make ci-terraform        # For Terraform
make ci-tofu             # For OpenTofu

# Run specific tests
make test-terratest      # Run all Terratest tests
make test-basic          # Test basic user creation
make test-multiple       # Test multiple users
make test-plan           # Test plan generation
make test-validate       # Test validation

# Run security tests
make test-terraform-security
make test-tofu-security
```

### CI/CD Pipeline

The `ci` target runs a complete pipeline suitable for CI/CD:

```bash
make ci-terraform
make ci-terraform-apply
make ci-tofu
make ci-tofu-apply
```

This executes:
1. Terraform/OpenTofu initialization
2. Terraform/OpenTofu validate
3. TFLint initialization
4. TFLint code quality check
5. Checkov security scan
6. Execution plan generation (optional)

### Terratest Integration Tests

Run automated infrastructure tests using Terratest:

```bash
# Run all Terratest tests
make test-terratest

# Run individual test scenarios
make test-basic          # Basic user creation
make test-multiple       # Multiple users with different roles
make test-plan           # Plan-only test (no apply)
make test-validate       # Validation test
```

## 📚 Module Reference

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.6.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement_proxmox) | >= 0.63.3 |

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider_proxmox) | >= 0.63.3 |

#### Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_user.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_user) | resource |

#### Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_comment"></a> [comment](#input_comment) | n/a | `string` | no |
| <a name="input_enabled_account"></a> [enabled_account](#input_enabled_account) | n/a | `bool` | no |
| <a name="input_path"></a> [path](#input_path) | n/a | `string` | yes |
| <a name="input_propagate"></a> [propagate](#input_propagate) | n/a | `bool` | no |
| <a name="input_role_id"></a> [role_id](#input_role_id) | n/a | `string` | yes |
| <a name="input_secret"></a> [secret](#input_secret) | n/a | `string` | yes |
| <a name="input_user_id"></a> [user_id](#input_user_id) | n/a | `string` | yes |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_user"></a> [user](#output_user) | User ID, user_id, enabled status, and comment |
| <a name="output_user_acl"></a> [user_acl](#output_user_acl) | User ACL information including path, propagate setting, and role ID |
<!-- END_TF_DOCS -->

### Debugging

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
make terraform-plan

# Enable OpenTofu debug logging
export TF_LOG=DEBUG
make tofu-plan

# Clean up everything and start fresh
make clean-all
```

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Before Contributing

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow Terraform/OpenTofu best practices
   - Update documentation
   - Add tests if applicable

4. **Run quality checks**
   ```bash
   make terraform-format
   make tflint-check
   ```

5. **Commit with clear messages**
   ```bash
   # For new features
   git commit -m "feat: add new feature"
   
   # For bug fixes
   git commit -m "fix: resolve issue with user permissions"
   
   # For documentation updates
   git commit -m "docs: update README examples"
   
   # For refactoring
   git commit -m "refactor: improve code structure"
   ```

6. **Submit a pull request**

### Development Guidelines

- ✅ Always run `make checkov-scan` before committing
- ✅ Ensure all tests pass with `ci-terraform` or `ci-tofu`
- ✅ Follow semantic versioning
- ✅ Update README for new features
- ✅ Add examples for new functionality
- ✅ Document any breaking changes

### Code Style

- Use descriptive variable names
- Add comments for complex logic
- Follow the existing code structure

## 📖 Additional Resources

### Documentation
- [Proxmox Provider Documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/language/modules/develop)
- [OpenTofu Documentation](https://opentofu.org/docs/)
- [Checkov Documentation](https://www.checkov.io/)
- [TFLint Documentation](https://github.com/terraform-linters/tflint)

### Community
- [Proxmox Forum](https://forum.proxmox.com/)
- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core)
- [OpenTofu Community](https://opentofu.org/community/)

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

**Made with ❤️ for the Proxmox and Terraform/OpenTofu community**

