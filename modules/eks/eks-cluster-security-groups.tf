
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
  description              = "Allow bastion to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster-cluster.id
  source_security_group_id = var.bastion_security_group_id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_cluster-cluster-peer-ingress" {
  for_each          = { for index, obj in var.eks_api_endpoint_access_cidrs : obj.from => obj }
  type              = "ingress"
  description       = "Allow peer bridge to communicate with the cluster API Server"
  security_group_id = aws_security_group.eks_cluster-cluster.id
  cidr_blocks       = [each.value.from]
  protocol          = "tcp"
  from_port         = each.value.port
  to_port           = each.value.port
}

