data "aws_partition" "this" {}

data "template_file" "userdata" {
  template = file("${path.module}/userdata.sh")
  vars = {
    http_proxy       = var.bastion.http_proxy
    https_proxy      = var.bastion.https_proxy
    no_proxy         = var.bastion.no_proxy
    kubectl_version  = var.bastion.kubectl_version
    helm_version     = var.bastion.helm_version
    helmfile_version = var.bastion.helmfile_version
    cluster_name     = var.cluster_name
    region           = var.region
  }
}

data "template_file" "ds_agent" {
  template = file("${path.module}/ds_agent.sh")
  vars     = {}
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.userdata.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.ds_agent.rendered
  }
}

resource "aws_instance" "bastion" {
  count = var.bastion.hosts_number

  ami                         = var.bastion.ami_id
  instance_type               = var.bastion.instance_type
  subnet_id                   = var.bastion.subnet_ids[count.index]
  associate_public_ip_address = var.bastion.public_access
  vpc_security_group_ids      = [aws_security_group.bastion_security_group.id]
  user_data_base64            = data.template_cloudinit_config.config.rendered
  iam_instance_profile        = aws_iam_instance_profile.bastion_ec2_role.name
  user_data_replace_on_change = true

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name                          = "${var.cluster_name}-bastion"
    "eks:cluster-name"            = var.cluster_name
    PatchGroup                    = "solace"
    Custodian-Scheduler-StopTime  = "off=(M-S,21);tz=sgt"
    Custodian-Scheduler-StartTime = "on=(M-F,8);tz=sgt"
    malware-scan                  = "true"
  }
}

resource "aws_instance" "bastion_1" {
  count = var.bastion.hosts_number

  ami                         = var.bastion.ami_id_green
  instance_type               = var.bastion.instance_type
  subnet_id                   = var.bastion.subnet_ids[count.index]
  associate_public_ip_address = var.bastion.public_access
  vpc_security_group_ids      = [aws_security_group.bastion_security_group.id]
  user_data_base64            = data.template_cloudinit_config.config.rendered
  iam_instance_profile        = aws_iam_instance_profile.bastion_ec2_role.name
  user_data_replace_on_change = true

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name                          = "${var.cluster_name}-bastion"
    "eks:cluster-name"            = var.cluster_name
    PatchGroup                    = "solace"
    Custodian-Scheduler-StopTime  = "off=(M-S,21);tz=sgt"
    Custodian-Scheduler-StartTime = "on=(M-F,8);tz=sgt"
    malware-scan                  = "true"
  }
}

resource "aws_security_group" "bastion_security_group" {
  name_prefix = "${var.cluster_name}_bastion_security_group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "bastion-egress-cidrs" {
  for_each          = { for index, obj in var.bastion_egress : md5("${obj.from_port}/${obj.to_port}/${obj.description}") => obj }
  type              = "egress"
  description       = each.value.description
  security_group_id = aws_security_group.bastion_security_group.id
  cidr_blocks       = each.value.cidrs
  protocol          = "tcp"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
}


resource "aws_security_group_rule" "bastion-ingress-cidrs" {
  for_each          = { for index, obj in var.bastion_secgrp_ingress_cidr : index => obj }
  type              = "ingress"
  description       = each.value.description
  security_group_id = aws_security_group.bastion_security_group.id
  cidr_blocks       = each.value.cidrs
  protocol          = "tcp"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
}

resource "aws_security_group_rule" "bastion-ingress-prefix" {
  for_each          = { for index, obj in var.bastion_secgrp_ingress_prefix_list : index => obj }
  type              = "ingress"
  description       = each.value.description
  security_group_id = aws_security_group.bastion_security_group.id
  prefix_list_ids   = each.value.prefix_list_ids
  protocol          = "tcp"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
}

resource "aws_security_group_rule" "bastion-ingress-secgrp" {
  for_each                 = { for index, obj in var.bastion_secgrp_ingress_secgrp : index => obj }
  type                     = "ingress"
  description              = each.value.description
  security_group_id        = aws_security_group.bastion_security_group.id
  source_security_group_id = each.value.secgrp_id
  protocol                 = "tcp"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
}