
resource "aws_security_group" "eks_cluster-cluster" {
  name        = "${var.cluster_name}-cluster-secgrp"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "eks_cluster-cluster-ingress" {
  for_each          = { for index, obj in var.eks_api_endpoint_access_cidrs : md5("${obj.from}/${obj.port}/${obj.description}") => obj }
  type              = "ingress"
  description       = each.value.description
  security_group_id = aws_security_group.eks_cluster-cluster.id
  cidr_blocks       = [each.value.from]
  protocol          = "tcp"
  from_port         = each.value.port
  to_port           = each.value.port
}

resource "aws_security_group_rule" "eks_cluster-cluster-egress" {
  for_each          = { for index, obj in var.eks_cluster_egress_access_cidrs : md5("${obj.from}/${obj.port}/${obj.description}") => obj }
  type              = "egress"
  description       = each.value.description
  security_group_id = aws_security_group.eks_cluster-cluster.id
  cidr_blocks       = [each.value.from]
  protocol          = "tcp"
  from_port         = each.value.port
  to_port           = each.value.port
}

