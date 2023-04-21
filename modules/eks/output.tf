output "k8s-endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "k8s-version" {
  value = aws_eks_cluster.eks_cluster.version
}

output "cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_role_name" {
  value = aws_iam_role.eks_cluster.name
}

output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_name" {
  value = aws_iam_role.eks_cluster-node.name
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_cluster-node.arn
}

output "aws_partition_name" {
  value = data.aws_partition.this.partition
}

output "aws_account_id" {
  value = data.aws_caller_identity.this.account_id
}

output "storage_class_gp2" {
  value = kubernetes_storage_class.gp2
}

output "storage_class_gp3" {
  value = kubernetes_storage_class.gp2
}

output "cluster_secgrp_ids" {
  value = [aws_security_group.eks_cluster-cluster.id, aws_security_group.eks_cluster-node.id]
}

output "cluster_node_secgrp_id" {
  value = [aws_security_group.eks_cluster-node.id]
}