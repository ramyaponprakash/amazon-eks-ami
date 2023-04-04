resource "aws_eks_node_group" "monitoring" {
  scaling_config {
    desired_size = var.node_groups_settings_messaging.desired_size
    max_size     = var.node_groups_settings_messaging.max_size
    min_size     = var.node_groups_settings_messaging.min_size
  }

  node_role_arn = var.eks_node_role_arn
  subnet_ids    = [var.eks_private_subnet_ids[length(var.eks_private_subnet_ids) - 1]]

  cluster_name           = var.cluster_name
  node_group_name_prefix = "${var.cluster_name}-monitoring-"
  instance_types         = [var.node_groups_monitoring_instance_type]

  labels = var.labels_taints_monitoring.labels

  dynamic "taint" {
    for_each = var.labels_taints_monitoring.taints
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  lifecycle {
    ignore_changes  = [scaling_config[0].desired_size]
    prevent_destroy = true
  }
}

data "aws_autoscaling_group" "monitoring" {
  name = aws_eks_node_group.monitoring.resources.0.autoscaling_groups.0.name
}

data "aws_arn" "monitoring" {
  arn = data.aws_autoscaling_group.monitoring.arn
}

resource "null_resource" "monitoring-asg-tags" {
  triggers = {
    "asg"    = data.aws_autoscaling_group.monitoring.arn
    "tags"   = jsonencode(var.asg_messaging_tags)
    "labels" = jsonencode(var.labels_taints_monitoring.labels)
    "taints" = jsonencode(var.labels_taints_monitoring.taints)
  }

  provisioner "local-exec" {
    command = <<EOF

    aws autoscaling create-or-update-tags --region ${data.aws_arn.monitoring.region} --tags '${jsonencode({
    "ResourceId" : data.aws_autoscaling_group.monitoring.name
    "ResourceType" : "auto-scaling-group",
    "Key" : "Custodian-Scheduler-StopTime",
    "Value" : "off=();tz=sgt",
    "PropagateAtLaunch" : true
    })}'

    aws autoscaling create-or-update-tags --region ${data.aws_arn.monitoring.region} --tags '${jsonencode({
    "ResourceId" : data.aws_autoscaling_group.monitoring.name
    "ResourceType" : "auto-scaling-group",
    "Key" : "Name",
    "Value" : aws_eks_node_group.monitoring.node_group_name,
    "PropagateAtLaunch" : true
    })}'

    aws autoscaling create-or-update-tags --region ${data.aws_arn.monitoring.region} --tags '${jsonencode([for i in var.asg_messaging_tags : {
      "ResourceId" : data.aws_autoscaling_group.monitoring.name
      "ResourceType" : "auto-scaling-group",
      "Key" : "k8s.io/cluster-autoscaler/node-template/${i.type}/${i.key}",
      "Value" : i.value,
      "PropagateAtLaunch" : true
      }])}'

    aws autoscaling create-or-update-tags --region ${data.aws_arn.monitoring.region} --tags '${jsonencode([for k, v in var.labels_taints_monitoring.labels : {
      "ResourceId" : data.aws_autoscaling_group.monitoring.name
      "ResourceType" : "auto-scaling-group",
      "Key" : "k8s.io/cluster-autoscaler/node-template/label/${k}",
      "Value" : v,
      "PropagateAtLaunch" : true
      }])}'

    aws autoscaling create-or-update-tags --region ${data.aws_arn.monitoring.region} --tags '${jsonencode([for i in var.labels_taints_monitoring.taints : {
      "ResourceId" : data.aws_autoscaling_group.monitoring.name
      "ResourceType" : "auto-scaling-group",
      "Key" : "k8s.io/cluster-autoscaler/node-template/taint/${i.key}",
      "Value" : "${i.value}:${replace(title(replace(lower(i.effect), "_", " ")), " ", "")}",
      "PropagateAtLaunch" : true
}])}'
    EOF
}
}