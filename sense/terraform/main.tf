provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket  = "sense-eks-infra-tf-state"
    key     = "adex/terraform/tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}
