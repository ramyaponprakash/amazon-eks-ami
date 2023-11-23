#############################
# EKS Cluster Resources
#  * EKS Cluster
#############################

resource "aws_cloudwatch_log_group" "sdx-eks-loggroup" {
  count             = 1
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days
  kms_key_id        = var.cluster_log_kms_key_id
  tags = {
    Name        = var.eks_cw_loggroup
    Environment = var.environment
  }
}

resource "aws_eks_cluster" "sdx-eks-cluster" {
  count                     = 1
  name                      = var.cluster_name
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  version                   = var.cluster_version
  role_arn                  = aws_iam_role.sdx-eks-cluster.arn

  vpc_config {
    security_group_ids      = [aws_security_group.sdx-eks-cluster-additional-secgrup.id]
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  encryption_config {
    provider {
      key_arn = var.cluster_kms_key_arn
    }
    resources = ["secrets"]
  }

  timeouts {
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
  }

  depends_on = [
    aws_iam_role_policy_attachment.sdx-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.sdx-cluster-AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.sdx-eks-loggroup
  ]

  # DO NOT INCLUDE Custodian tag
  tags = {
    Type        = "cluster"
    Name        = var.cluster_name
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [version]
  }
}

resource "aws_eks_addon" "sdx-eks-cluster-kube-proxy-add-on" {
  cluster_name      = var.cluster_name
  addon_name        = "kube-proxy"
  resolve_conflicts = "OVERWRITE"
  #addon_version     = var.kube_proxy_version
  depends_on = [
    aws_eks_cluster.sdx-eks-cluster
  ]
}

resource "aws_eks_addon" "sdx-eks-cluster-vpc-cni-add-on" {
  cluster_name      = var.cluster_name
  addon_name        = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
  #addon_version     = var.vpc_cni_version
  depends_on = [
    aws_eks_cluster.sdx-eks-cluster
  ]
}

resource "aws_eks_addon" "sdx-eks-cluster-coredns-add-on" {
  cluster_name      = var.cluster_name
  addon_name        = "coredns"
  resolve_conflicts = "OVERWRITE"
  #addon_version     = var.coredns_version
  depends_on = [
    aws_eks_cluster.sdx-eks-cluster
  ]
}





