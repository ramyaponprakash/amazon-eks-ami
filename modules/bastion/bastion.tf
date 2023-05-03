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

resource "tls_private_key" "generated_sshkey" {
  count     = var.bastion.generate_private_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_keypair" {
  key_name   = "keypair-${var.cluster_name}"
  public_key = var.bastion.generate_private_key ? tls_private_key.generated_sshkey[0].public_key_openssh : file(var.bastion.public_key_path)
}

resource "aws_instance" "ubuntu_bastion" {
  count = var.bastion.hosts_number

  ami                         = var.bastion.ami_id
  instance_type               = var.bastion.instance_type
  key_name                    = aws_key_pair.generated_keypair.key_name
  subnet_id                   = var.bastion.subnet_ids[count.index]
  associate_public_ip_address = var.bastion.public_access
  vpc_security_group_ids      = [aws_security_group.bastion_security_group.id]
  user_data                   = data.template_file.userdata.rendered
  iam_instance_profile        = var.bastion.iam_role
  user_data_replace_on_change = true
  root_block_device {
    encrypted = true
  }

  tags = {
    Name                         = "${var.cluster_name}-${var.az_map[count.index]}"
    Custodian-Scheduler-StopTime = "off=();tz=sgt"
    malware-scan                 = "true"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

# Ensures that terraform waits until bastion host is up and running before leaving.
/*
resource "null_resource" "wait_for_bastion" {
  provisioner "remote-exec" {
    connection {
      host        = var.bastion.public_access ? var.bastion.attach_eip ? aws_eip.ubuntu_bastion_eip[0].public_ip : aws_instance.ubuntu_bastion[0].public_dns : aws_instance.ubuntu_bastion[0].private_dns
      user        = "ubuntu"
      private_key = var.bastion.generate_private_key ? tls_private_key.generated_sshkey[0].private_key_pem : file(var.bastion.host_private_key_path)
    }
    inline = [
      "#!/bin/bash",
      "while ! command -v kubectl &> /dev/null; do sleep 5; done",
      "while ! command -v helm &> /dev/null; do sleep 5; done",
      "while ! command -v aws &> /dev/null; do sleep 5; done",
    ]
  }

  depends_on = [
    aws_instance.ubuntu_bastion[0]
  ]
}
*/

resource "aws_security_group" "bastion_security_group" {
  name   = "${var.cluster_name}_bastion_security_group"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ubuntu_bastion_eip" {
  count = var.bastion.public_access ? var.bastion.attach_eip ? 1 : 0 : 0

  vpc      = true
  instance = aws_instance.ubuntu_bastion[0].id

  tags = {
    Name = "${var.cluster_name}_bastion_eip"
  }
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