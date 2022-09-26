#############################
# EKS Cluster Resources
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * Cluster Security Group: created by EKS automatically, it will be used by NodeGroup
#  * Additional Security Group: only used by control plain and worker nodes
#############################

resource "aws_security_group" "sdx-eks-cluster-additional-secgrup" {
  vpc_id      = var.cluster_vpc
  name        = "sgrp-${var.cluster_name}-cluster-additional"
  description = "Control communications from the Kubernetes control plane to compute resources, will not attach to Nodes"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.cidr_blocks_additional_secgrp
    description = "var.cidr_blocks_additional_secgrp"
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.cidr_blocks_additional_secgrp
    description = "var.cidr_blocks_additional_secgrp"
  }

  tags = {
    Name                         = "sgrp-${var.cluster_name}-cluster-additional"
    Custodian-Scheduler-StopTime = "off=();tz=sgt"
    Custodian-IgnoreSG           = "True" # in case of testing with 0.0.0.0
  }
}


resource "aws_security_group" "sgrp-sdx-eks-ssh" {
  vpc_id      = var.cluster_vpc
  name        = "sgrp-sdx-${var.environment}-eks-ssh"
  description = "bastion ssh"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.cidr_blocks_bastion_ssh
    description = "from Nessus"
  }
  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    prefix_list_ids = var.prefix_list_ids_bastion_ssh
    description     = "from sdx team"
  }
  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    prefix_list_ids = ["pl-0b206207dd31eb6e6"]
    description     = "from ship"
  }

  tags = {
    Name                         = "sgrp-sdx-${var.environment}-ssh"
    Custodian-Scheduler-StopTime = "off=();tz=sgt"
  }
}
