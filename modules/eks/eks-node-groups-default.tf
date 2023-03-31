// NOTE: need 1 default node to init cluster and add-ons

resource "aws_eks_node_group" "eks_default_nodegroup" {
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 0
  }

  node_role_arn = aws_iam_role.eks_cluster-node.arn
  subnet_ids    = var.eks_private_subnet_ids

  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-default-node-group"
  instance_types  = ["t3.medium"]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
    #    prevent_destroy = true
  }

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

data "aws_autoscaling_group" "default_node_group" {
  name = aws_eks_node_group.eks_default_nodegroup.resources.0.autoscaling_groups.0.name
}

data "aws_arn" "default_node_group" {
  arn = aws_eks_node_group.eks_default_nodegroup.arn
}

resource "null_resource" "default_node_group_asg_tags" {
  triggers = {
    "asg" = data.aws_autoscaling_group.default_node_group.arn
  }

  provisioner "local-exec" {
    command = <<EOF
    aws autoscaling create-or-update-tags --region ${data.aws_arn.default_node_group.region} --tags '${jsonencode({
    "ResourceId" : data.aws_autoscaling_group.default_node_group.name
    "ResourceType" : "auto-scaling-group",
    "Key" : "Custodian-Scheduler-StopTime",
    "Value" : "off=();tz=sgt",
    "PropagateAtLaunch" : true
    })}'

    aws autoscaling create-or-update-tags --region ${data.aws_arn.default_node_group.region} --tags '${jsonencode({
    "ResourceId" : data.aws_autoscaling_group.default_node_group.name
    "ResourceType" : "auto-scaling-group",
    "Key" : "Name",
    "Value" : aws_eks_node_group.eks_default_nodegroup.node_group_name,
    "PropagateAtLaunch" : true
})}'
EOF
}
}