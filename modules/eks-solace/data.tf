data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_ssm_parameter" "optimized-ami" {
  name = "/aws/service/eks/optimized-ami/${data.aws_eks_cluster.eks_cluster.version}/amazon-linux-2/recommended/image_id"
}

locals {
  cluster_secgrp_ids = distinct(concat(
    [data.aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id],
    tolist(data.aws_eks_cluster.eks_cluster.vpc_config[0].security_group_ids),
  ))
}