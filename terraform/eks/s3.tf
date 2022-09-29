#resource "aws_s3_bucket" "sdx-eks-artifacts" {
#  bucket = "sdx-eks-artifacts"
#
#  tags = {
#    Name = "sdx-eks-artifacts"
#  }
#}
#
#resource "aws_s3_bucket_server_side_encryption_configuration" "sdx-eks-artifacts-encryption" {
#  bucket = aws_s3_bucket.sdx-eks-artifacts.id
#
#  rule {
#    apply_server_side_encryption_by_default {
#      kms_master_key_id = "aws/s3"
#      sse_algorithm     = "aws:kms"
#    }
#  }
#}
#
#resource "aws_s3_bucket_acl" "sdx-eks-artifacts-acl" {
#  bucket = aws_s3_bucket.sdx-eks-artifacts.id
#  acl    = "private"
#}
#
#resource "aws_s3_bucket_versioning" "sdx-eks-artifacts-versioning" {
#  bucket = aws_s3_bucket.sdx-eks-artifacts.id
#  versioning_configuration {
#    status = "Enabled"
#  }
#}
#
#resource "aws_s3_bucket_public_access_block" "sdx-eks-artifacts-public-block" {
#  bucket = aws_s3_bucket.sdx-eks-artifacts.id
#
#  block_public_acls       = true
#  block_public_policy     = true
#  ignore_public_acls      = true
#  restrict_public_buckets = true
#}
#
#resource "aws_s3_bucket_logging" "sdx-eks-artifacts-access-log" {
#  bucket = aws_s3_bucket.sdx-eks-artifacts.id
#
#  target_bucket = aws_s3_bucket.sdx-eks-artifacts.id
#  target_prefix = "log/"
#}