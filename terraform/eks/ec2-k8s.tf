data "template_file" "sdx_kube_bastion_blue_userdata" {
    template = file("${path.module}/userdata/sdx_kube_bastion_blue_userdata.sh")
    vars     = {
           kubectl_version        = var.kubectl_version
           helm_version           = var.helm_version
           helmfile_version       = var.helmfile_version
       }
}

resource "aws_instance" "sdx_kube_bastion" {
  count                  = 1
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.sense_key
  subnet_id              = var.subnet_id_bastion
  vpc_security_group_ids = [aws_security_group.sgrp-sdx-dev-ssh.id]
  user_data              = data.template_file.sdx_kube_bastion_blue_userdata.rendered
  root_block_device {
    volume_type                   = "standard"
    volume_size                   = 30
  }
  lifecycle {
    ignore_changes                = all
  }
  tags = {
    Name                          = "sdx-${var.environment}-kube-bastion"
    Custodian-Scheduler-StopTime  = "off=();tz=sgt"
    Environment                   = var.environment
  }
}