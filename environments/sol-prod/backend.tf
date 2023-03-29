terraform {
  backend "s3" {
    bucket  = "adex-prd-tf-state"
    key     = "solace-prd/terraform/tfstate"
    region  = "ap-southeast-1"
    encrypt = true
    # dynamodb_table = "terraform-state-lock" // TODO
  }
}