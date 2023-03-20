# Once aws_eks_node_group create managed ASG, will tag to the existing ASG to be propagate to worker nodes on launch
resource "aws_autoscaling_group_tag" "nodegroup-tag-name" {
  for_each = var.default_nodegroup_asg

  autoscaling_group_name = each.value

  tag {
    key                 = "Name"
    value               = "eks-${var.cluster_name}-default-nodegroup-worker-node"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "nodegroup-tag-env" {
  for_each = var.default_nodegroup_asg

  autoscaling_group_name = each.value

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "nodegroup-tag-custodian" {
  for_each = var.default_nodegroup_asg

  autoscaling_group_name = each.value

  tag {
    key                 = "Custodian-Scheduler-StopTime"
    value               = "off=();tz=sgt"
    propagate_at_launch = true
  }
}
