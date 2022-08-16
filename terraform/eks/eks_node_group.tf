
#
# EKS Worker Nodes Resources
#  * EKS Node Group to launch worker nodes
#


resource "aws_eks_node_group" "sdx-eks-blue-node" {
  cluster_name    = var.cluster_name
  node_group_name = "sdx_eks_blue_nodegroup"
  node_role_arn   = aws_iam_role.sdx-eks-node.arn
  subnet_ids      = var.eks_nodegroup_subnet_ids
  instance_types  = [var.instance_type]

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  remote_access {
    ec2_ssh_key   = var.sense_key
  }

  labels   = {
    Name         = "sdx_eks_worker_blue_nodegroup"
  }

  tags     = {
    Name         = "sdx_eks_worker_blue_nodegroup"
    Environment = var.environment
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.sdx-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.sdx-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.sdx-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}