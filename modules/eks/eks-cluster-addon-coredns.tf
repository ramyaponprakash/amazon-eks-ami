resource "aws_eks_addon" "core_dns" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "coredns"
  resolve_conflicts = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.default_nodegroup
  ]
}