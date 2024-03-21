data "aws_partition" "this" {}

data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

data "aws_iam_session_context" "this" {
  arn = data.aws_caller_identity.this.arn
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.eks_cluster.id
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_cluster.id
}

data "aws_eks_cluster" "cluster_name" {
  name = aws_eks_cluster.eks_cluster.name
}

data "aws_ami" "latest-cis-optimized-ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["adex-sol-eks-node-${data.aws_eks_cluster.cluster.version}*"]
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}
