terraform {
  backend "s3" {
    bucket  = "sense-eks-infra-tf-state"
    key     = "sense/solace/solace-poc/terraform/tfstate"
    region  = "ap-southeast-1"
    encrypt = true
    # dynamodb_table = "terraform-state-lock" // TODO
  }
}