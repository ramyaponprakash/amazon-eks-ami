#############################
# EKS Cluster Resources
#  * EKS Cluster
#############################

resource "aws_cloudwatch_log_group" "sdx-eks-loggroup" {
  count             = 1
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days
  #kms_key_id       = var.cluster_log_kms_key_id
  tags              = {
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
    security_group_ids      = [aws_security_group.sdx-eks-cluster.id]
    subnet_ids              = var.subnet_ids
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

   tags      = {
    Name        = "sdx-eks-${var.environment}-blue-cluster"
    Environment = var.environment
  }
}



