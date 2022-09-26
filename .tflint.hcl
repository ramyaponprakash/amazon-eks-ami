plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_required_providers" {
  enabled = false
}
rule "terraform_unused_declarations" {
  enabled = false
}
rule "terraform_deprecated_index" {
  enabled = false
}

plugin "aws" {
  enabled = true
  deep_check = true
  version = "0.17.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
