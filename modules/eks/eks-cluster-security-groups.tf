
resource "aws_security_group" "eks_cluster-cluster" {
  name        = "${var.cluster_name}-cluster-secgrp"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "eks_cluster-cluster-bastion" {
  # count                    = var.bastion_security_group_id != "" ? 1 : 0
  description              = "Allow bastion to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster-cluster.id
  source_security_group_id = var.bastion_security_group_id
  to_port                  = 443
  type                     = "ingress"
}

