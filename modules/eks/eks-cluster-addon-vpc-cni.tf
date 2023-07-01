resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.default_nodegroup
  ]
}