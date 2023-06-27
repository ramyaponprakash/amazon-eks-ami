data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

data "aws_ami" "latest-cis-optimized-ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["adex-sol-eks-node-${var.k8s_master_version}*"]
  }
}

locals {
  cluster_secgrp_ids = distinct(concat(
    [data.aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id],
    tolist(data.aws_eks_cluster.eks_cluster.vpc_config[0].security_group_ids),
  ))
}