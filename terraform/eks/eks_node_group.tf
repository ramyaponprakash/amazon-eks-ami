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
    desired_size = 4
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
  lifecycle {
    ignore_changes = all
  }

  # nodegroup tag will not propagate to ASG or worker node
  # DO NOT INCLUDE Custodian tag
  tags = {
    Type        = "nodegroup"
    Name        = "${var.cluster_name}-default-nodegroup"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.sdx-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.sdx-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.sdx-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Once aws_eks_node_group create managed ASG, will tag to the existing ASG to be propagate to worker nodes on launch
resource "aws_autoscaling_group_tag" "nodegroup-tag-name" {
  for_each = toset(
    [for asg in flatten(
      [for resources in aws_eks_node_group.sdx-eks-default-nodegroup.resources : resources.autoscaling_groups]
    ) : asg.name]
  )

  autoscaling_group_name = each.value

  tag {
    key                 = "Name"
    value               = "eks-${var.cluster_name}-default-nodegroup-worker-node"
    propagate_at_launch = true
  }

  depends_on = [
    aws_eks_node_group.sdx-eks-default-nodegroup
  ]
}

resource "aws_autoscaling_group_tag" "nodegroup-tag-env" {
  for_each = toset(
    [for asg in flatten(
      [for resources in aws_eks_node_group.sdx-eks-default-nodegroup.resources : resources.autoscaling_groups]
    ) : asg.name]
  )

  autoscaling_group_name = each.value

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  depends_on = [
    aws_eks_node_group.sdx-eks-default-nodegroup
  ]
}

resource "aws_autoscaling_group_tag" "nodegroup-tag-custodian" {
  for_each = toset(
    [for asg in flatten(
      [for resources in aws_eks_node_group.sdx-eks-default-nodegroup.resources : resources.autoscaling_groups]
    ) : asg.name]
  )

  autoscaling_group_name = each.value

  tag {
    key                 = "Custodian-Scheduler-StopTime"
    value               = "off=();tz=sgt"
    propagate_at_launch = true
  }

  depends_on = [
    aws_eks_node_group.sdx-eks-default-nodegroup
  ]
}
