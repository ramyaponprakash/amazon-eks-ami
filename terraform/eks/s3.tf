resource "aws_s3_bucket" "sdx-eks-artifacts" {
  bucket = "sdx-eks-artifacts"

  tags = {
    Name = "sdx-eks-artifacts"
  }
}

resource "aws_s3_bucket_acl" "sdx-eks-artifacts-acl" {
  bucket = aws_s3_bucket.sdx-eks-artifacts.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "sdx-eks-artifacts-versioning" {
  bucket = aws_s3_bucket.sdx-eks-artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}