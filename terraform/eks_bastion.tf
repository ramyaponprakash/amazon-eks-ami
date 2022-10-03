data "template_file" "sdx_kube_bastion_userdata" {
  template = file("${path.module}/userdata/sdx_kube_bastion_userdata.sh")
  vars = {
    kubectl_version  = var.kubectl_version
    helm_version     = var.helm_version
    helmfile_version = var.helmfile_version
    cluster_name     = var.cluster_name
    region           = var.region
  }
}

resource "aws_instance" "sdx_kube_bastion" {
  count                       = 1
  ami                         = var.bastion_ami
  instance_type               = var.instance_type_bastion
  key_name                    = var.sense_key
  iam_instance_profile        = "ec2-eks-role"
  subnet_id                   = var.subnet_id_bastion
  vpc_security_group_ids      = var.vpc_bastion_security_group
  user_data                   = data.template_file.sdx_kube_bastion_userdata.rendered
  associate_public_ip_address = true
  root_block_device {
    volume_type = "standard"
    volume_size = 30
    encrypted   = true
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
  }
  /*lifecycle {
    ignore_changes = all
  }*/
  tags = {
    Name                         = "sdx-${var.environment}-kube-bastion"
    Custodian-Scheduler-StopTime = "off=();tz=sgt"
    Environment                  = var.environment
  }
}