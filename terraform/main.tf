provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  backend "s3" {
    bucket = "sense-eks-infra-tf-state"
    key    = "sense/terraform/tfstate"
    region = "ap-southeast-1"
    encrypt = true
  }
}