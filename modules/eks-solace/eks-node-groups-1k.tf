resource "aws_eks_node_group" "prod1k" {
  count = var.node_groups_count_messaging

  scaling_config {
    desired_size = var.node_groups_settings_messaging.desired_size
    max_size     = var.node_groups_settings_messaging.max_size
    min_size     = var.node_groups_settings_messaging.min_size
  }

  node_role_arn = var.eks_node_role_arn
  subnet_ids    = [var.eks_private_subnet_ids[count.index]]

  cluster_name           = var.cluster_name
  node_group_name_prefix = "${var.cluster_name}-prod1k-${count.index}-"
  instance_types         = [var.node_groups_1k_instance_type]

  labels = var.labels_taints_prod1k.labels

  dynamic "taint" {
    for_each = var.labels_taints_prod1k.taints
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
    #    prevent_destroy = true
  }
}

data "aws_autoscaling_group" "prod1k" {
  count = var.node_groups_count_messaging
  name  = aws_eks_node_group.prod1k[count.index].resources.0.autoscaling_groups.0.name
}

data "aws_arn" "prod1k" {
  count = var.node_groups_count_messaging
  arn   = aws_eks_node_group.prod1k[count.index].arn
}

resource "null_resource" "prod1k-asg-tags" {
  count = var.node_groups_count_messaging

  triggers = {
    "asg"    = data.aws_autoscaling_group.prod1k[count.index].arn
    "tags"   = jsonencode(var.asg_messaging_tags)
    "labels" = jsonencode(var.labels_taints_prod1k.labels)
    "taints" = jsonencode(var.labels_taints_prod1k.taints)
  }

  provisioner "local-exec" {
    command = <<EOF

    aws autoscaling create-or-update-tags --region ${data.aws_arn.prod1k[count.index].region} --tags '${jsonencode({
    "ResourceId" : data.aws_autoscaling_group.prod1k[count.index].name
    "ResourceType" : "auto-scaling-group",
    "Key" : "Custodian-Scheduler-StopTime",
    "Value" : "off=();tz=sgt",
    "PropagateAtLaunch" : true
    })}'

    aws autoscaling create-or-update-tags --region ${data.aws_arn.prod1k[count.index].region} --tags '${jsonencode({
    "ResourceId" : data.aws_autoscaling_group.prod1k[count.index].name
    "ResourceType" : "auto-scaling-group",
    "Key" : "Name",
    "Value" : aws_eks_node_group.prod1k[count.index].node_group_name,
    "PropagateAtLaunch" : true
    })}'

    aws autoscaling create-or-update-tags --region ${data.aws_arn.prod1k[count.index].region} --tags '${jsonencode([for i in var.asg_messaging_tags : {
      "ResourceId" : data.aws_autoscaling_group.prod1k[count.index].name
      "ResourceType" : "auto-scaling-group",
      "Key" : "k8s.io/cluster-autoscaler/node-template/${i.type}/${i.key}",
      "Value" : i.value,
      "PropagateAtLaunch" : true
      }])}'

    aws autoscaling create-or-update-tags --region ${data.aws_arn.prod1k[count.index].region} --tags '${jsonencode([for k, v in var.labels_taints_prod1k.labels : {
      "ResourceId" : data.aws_autoscaling_group.prod1k[count.index].name
      "ResourceType" : "auto-scaling-group",
      "Key" : "k8s.io/cluster-autoscaler/node-template/label/${k}",
      "Value" : v,
      "PropagateAtLaunch" : true
      }])}'

    aws autoscaling create-or-update-tags --region ${data.aws_arn.prod1k[count.index].region} --tags '${jsonencode([for i in var.labels_taints_prod1k.taints : {
      "ResourceId" : data.aws_autoscaling_group.prod1k[count.index].name
      "ResourceType" : "auto-scaling-group",
      "Key" : "k8s.io/cluster-autoscaler/node-template/taint/${i.key}",
      "Value" : "${i.value}:${replace(title(replace(lower(i.effect), "_", " ")), " ", "")}",
      "PropagateAtLaunch" : true
}])}'
    EOF
}
}