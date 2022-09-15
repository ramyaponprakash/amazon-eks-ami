#
# EKS Worker Nodes Resources
#  * EKS Node Group to launch worker nodes
#

resource "aws_eks_node_group" "sdx-eks-default-nodegroup" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-default-nodegroup"
  node_role_arn   = aws_iam_role.sdx-eks-node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = [var.instance_type]

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  remote_access {
    ec2_ssh_key = var.sense_key
  }

  # k8 label for node
  labels = {
    Type     = "default"
    Instance = var.instance_type
  }

  # aws tag
  tags = {
    Name                         = "${var.cluster_name}-default-nodegroup"
    Custodian-Scheduler-StopTime = "off=();tz=sgt"
    Environment                  = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.sdx-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.sdx-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.sdx-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}