resource "aws_eks_node_group" "monitoring" {
  scaling_config {
    desired_size = var.node_groups_settings_messaging.desired_size
    max_size     = var.node_groups_settings_messaging.max_size
    min_size     = var.node_groups_settings_messaging.min_size
  }

  node_role_arn = var.eks_node_role_arn
  subnet_ids    = [var.eks_private_subnet_ids[length(var.eks_private_subnet_ids) - 1]]

  cluster_name           = var.cluster_name
  node_group_name_prefix = "${var.cluster_name}-moni-"

  labels = var.labels_taints_monitoring.labels

  launch_template {
    id      = aws_launch_template.monitoring.id
    version = aws_launch_template.monitoring.default_version
  }

  dynamic "taint" {
    for_each = var.labels_taints_monitoring.taints
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  lifecycle {
    ignore_changes        = [scaling_config[0].desired_size]
    create_before_destroy = true
  }
}


resource "aws_launch_template" "monitoring" {
  name = "${var.cluster_name}-monitoring-ng-tmpl"

  image_id               = data.aws_ssm_parameter.optimized-ami.value
  vpc_security_group_ids = local.cluster_secgrp_ids

  instance_type          = var.node_groups_monitoring_instance_type
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/eks-node-groups-userdata.tpl",
    {
      CLUSTER_NAME   = data.aws_eks_cluster.eks_cluster.name
      B64_CLUSTER_CA = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data,
      API_SERVER_URL = data.aws_eks_cluster.eks_cluster.endpoint
      HTTP_PROXY     = var.eks_http_proxy
      NO_PROXY_HOST  = "${join(",", data.aws_vpc.vpc.cidr_block_associations[*].cidr_block)},localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,${var.eks_private_ep_no_proxy}${var.eks_additional_no_proxy}"
      NO_PROXY_POD   = "${join(",", data.aws_vpc.vpc.cidr_block_associations[*].cidr_block)},${data.aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr},localhost,127.0.0.1,169.254.169.254,.local,.internal,.eks.amazonaws.com,${var.eks_private_ep_no_proxy}${var.eks_additional_no_proxy}"
      MAX_POD        = "17"
    }
  ))

  metadata_options {
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      "Custodian-Scheduler-StopTime"              = "off=();tz=sgt"
    }
  }

  tags = {
    Name = "${var.cluster_name}-monitoring-ng-tmpl"
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