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

data "aws_ssm_parameter" "optimized-ami" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks_cluster.version}/amazon-linux-2/recommended/image_id"
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}
