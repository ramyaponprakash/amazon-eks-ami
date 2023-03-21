output "kubeconfig" {
  value     = local.kubeconfig
  sensitive = true
}

output "ssh_kubeconfig" {
  value     = local.ssh_kubeconfig
  sensitive = true
}

output "k8s-endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "k8s-version" {
  value = aws_eks_cluster.eks_cluster.version
}

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
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

