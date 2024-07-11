resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  version = var.k8s_master_version

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster-cluster.id, aws_security_group.eks_cluster-node.id]
    subnet_ids              = var.eks_private_subnet_ids
    endpoint_private_access = var.eks_cluster_endpoint_private
    endpoint_public_access  = var.eks_cluster_endpoint_public
  }

  kubernetes_network_config {
    service_ipv4_cidr = "10.100.0.0/16"
    ip_family         = "ipv4"
  }

  encryption_config {
    provider {
      key_arn = var.eks_customer_cmk_key_arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster-EKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster-EKSServicePolicy,
  ]

  tags = {
    Name   = var.cluster_name
    Access = "Public access by source allowlist in networking tab"
  }

  /*lifecycle {
    ignore_changes = [version]
  }*/
}