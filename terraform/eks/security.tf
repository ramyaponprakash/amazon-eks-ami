#############################
# EKS Cluster Resources
#  * EC2 Security Group to allow networking traffic with EKS cluster
#############################

resource "aws_security_group" "sdx-eks-cluster" {
    vpc_id      = var.sense_vpc
    name        = "sgrp-sdx-eks-cluster"
    description = "Cluster communication with worker nodes"    
    ingress {
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        cidr_blocks = ["0.0.0.0/0"]
     
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name                          = "sgrp-sdx-eks-cluster"
    Custodian-Scheduler-StopTime  = "off=();tz=sgt"
  }
}


resource "aws_security_group" "sgrp-sdx-dev-ssh" {
    vpc_id      = var.sense_vpc
    name        = "sgrp-sdx-${var.environment}-eks-ssh"
    description = "bastion ssh"    

    ingress {
        protocol        = "tcp"
        from_port       = 22
        to_port         = 22
        cidr_blocks     = var.cidr_blocks_bastion_ssh
        description     = "from Nessus"
     
    }
    ingress {
        protocol        = "tcp"
        from_port       = 22
        to_port         = 22
        prefix_list_ids = var.prefix_list_ids_bastion_ssh
        description     = "from sdx team"
     
    }
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
  }
   tags = {
        Name                          = "sgrp-sdx-${var.environment}-ssh"
        Custodian-Scheduler-StopTime  = "off=();tz=sgt"
  }
}