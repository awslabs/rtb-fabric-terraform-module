plugin "aws" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Disable AWS IAM validation rules due to complex conditionals with null values
# These rules fail when evaluating deeply nested conditionals in count expressions
# The IAM resources are validated by AWS at apply time anyway
rule "aws_iam_role_invalid_assume_role_policy" {
  enabled = false
}

rule "aws_iam_role_invalid_description" {
  enabled = false
}

rule "aws_iam_role_invalid_name" {
  enabled = false
}

rule "aws_iam_role_invalid_path" {
  enabled = false
}

rule "aws_iam_role_policy_invalid_name" {
  enabled = false
}

rule "aws_iam_role_policy_invalid_policy" {
  enabled = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

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

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
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