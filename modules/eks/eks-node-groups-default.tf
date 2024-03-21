// NOTE: need 1 default node to init cluster and add-ons

resource "aws_eks_node_group" "default_nodegroup" {
  scaling_config {
    desired_size = 1
    min_size     = 0
    max_size     = 2
  }

  node_role_arn          = aws_iam_role.eks_cluster-node.arn
  subnet_ids             = [var.eks_private_subnet_ids[0]] // Due to SOLI limitation
  cluster_name           = var.cluster_name
  node_group_name_prefix = "${var.cluster_name}-default-"

  launch_template {
    id      = aws_launch_template.default_nodegroup.id
    version = aws_launch_template.default_nodegroup.default_version
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.cluster_name}-default-ng"
  }

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size,
      launch_template[0].version,
    ]
    create_before_destroy = true
  }
}

# https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html
resource "aws_launch_template" "default_nodegroup" {
  name = "${var.cluster_name}-default-ng-tmpl"

  image_id               = data.aws_ami.latest-cis-optimized-ami.image_id
  vpc_security_group_ids = [aws_security_group.eks_cluster-node.id]

  instance_type          = "t3.medium"
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/eks-node-groups-userdata.tpl",
    {
      CLUSTER_NAME   = aws_eks_cluster.eks_cluster.name
      B64_CLUSTER_CA = aws_eks_cluster.eks_cluster.certificate_authority[0].data,
      API_SERVER_URL = aws_eks_cluster.eks_cluster.endpoint
      HTTP_PROXY     = var.eks_http_proxy
      NO_PROXY_HOST  = "${join(",", data.aws_vpc.vpc.cidr_block_associations[*].cidr_block)},localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,${var.eks_private_ep_no_proxy}${var.eks_additional_no_proxy}"
      NO_PROXY_POD   = "${join(",", data.aws_vpc.vpc.cidr_block_associations[*].cidr_block)},${aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr},${var.eks_default_no_proxy},${var.eks_private_ep_no_proxy}${var.eks_additional_no_proxy}"
      MAX_POD        = "17"
    }
  ))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
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
    "eks:cluster-name"   = var.cluster_name
    "eks:nodegroup-name" = "${var.cluster_name}-default"
  }
}

data "aws_autoscaling_group" "default_node_group" {
  name = aws_eks_node_group.default_nodegroup.resources.0.autoscaling_groups.0.name
}

data "aws_arn" "default_node_group" {
  arn = aws_eks_node_group.default_nodegroup.arn
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
    "Key" : "PatchGroup",
    "Value" : "solace",
    "PropagateAtLaunch" : true
    })}'

    aws autoscaling create-or-update-tags --region ${data.aws_arn.default_node_group.region} --tags '${jsonencode({
    "ResourceId" : data.aws_autoscaling_group.default_node_group.name
    "ResourceType" : "auto-scaling-group",
    "Key" : "Name",
    "Value" : aws_eks_node_group.default_nodegroup.node_group_name,
    "PropagateAtLaunch" : true
})}'
EOF
}
}