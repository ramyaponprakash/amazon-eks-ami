terraform {
  backend "s3" {
    bucket  = "adex-dev-tf-state"
    key     = "solace-poc/terraform/tfstate"
    region  = "ap-southeast-1"
    encrypt = true
    # dynamodb_table = "terraform-state-lock" // TODO
  }
}