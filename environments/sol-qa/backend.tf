terraform {
  backend "s3" {
    bucket  = "adex-qa-tf-state"
    key     = "solace-qa/terraform/tfstate"
    region  = "ap-southeast-1"
    encrypt = true
    # dynamodb_table = "terraform-state-lock" // TODO
  }
}