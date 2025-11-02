# TFLint configuration for Proxmox User module
# https://github.com/terraform-linters/tflint

# Enable the bundled Terraform language ruleset
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Configure rules
rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_module_version" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  
  # Resource naming convention
  resource {
    format = "snake_case"
  }
  
  # Variable naming convention
  variable {
    format = "snake_case"
  }
  
  # Output naming convention
  output {
    format = "snake_case"
  }
  
  # Local naming convention
  locals {
    format = "snake_case"
  }
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = false
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}

rule "terraform_workspace_remote" {
  enabled = true
}

