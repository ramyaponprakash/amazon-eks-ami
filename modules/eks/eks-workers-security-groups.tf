// Security group for the nodes
resource "aws_security_group" "eks_cluster-node" {
  name        = "${var.cluster_name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    Custodian-IgnoreSG                          = "True"
  }
}

resource "aws_security_group_rule" "eks_cluster-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_cluster-node.id
  source_security_group_id = aws_security_group.eks_cluster-node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_cluster-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster-node.id
  source_security_group_id = aws_security_group.eks_cluster-cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_cluster-node-ingress-lbc" {
  description              = "Allow access from control plane to webhook port of AWS load balancer controller"
  type                     = "ingress"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster-node.id
  source_security_group_id = aws_security_group.eks_cluster-cluster.id
  from_port                = 9443
  to_port                  = 9443
}

resource "aws_security_group_rule" "eks_cluster-node-ingress-cidrs" {
  for_each          = { for index, obj in var.eks_worker_node_access_cidrs : index => obj }
  type              = "ingress"
  description       = each.value.description
  security_group_id = aws_security_group.eks_cluster-node.id
  cidr_blocks       = each.value.cidrs
  protocol          = "tcp"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
}

resource "aws_security_group_rule" "eks_cluster-node-ingress-prefix-list" {
  for_each          = { for index, obj in var.eks_worker_node_access_prefix : index => obj }
  type              = "ingress"
  description       = each.value.description
  security_group_id = aws_security_group.eks_cluster-node.id
  prefix_list_ids   = each.value.prefix_list_ids
  protocol          = "tcp"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
}

resource "aws_security_group_rule" "eks_cluster-node-egress" {
  for_each                 = { for index, obj in var.eks_worker_node_egress_access_cidrs : index => obj }
  type                     = "egress"
  description              = each.value.description
  security_group_id        = aws_security_group.eks_cluster-node.id
  source_security_group_id = aws_security_group.eks_cluster-cluster.id
  protocol                 = "tcp"
  from_port                = each.value.port
  to_port                  = each.value.port
}

resource "aws_security_group_rule" "eks_cluster-node-egress-tcp-HA" {
  for_each                 = { for index, obj in var.eks_worker_node_egress_tcp_HA : index => obj }
  type                     = "egress"
  security_group_id        = aws_security_group.eks_cluster-node.id
  cidr_blocks              = each.value.cidrs
  protocol                 = "tcp"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
}

resource "aws_security_group_rule" "eks_cluster-node-egress-udp-HA" {
  for_each                 = { for index, obj in var.eks_worker_node_egress_udp_HA : index => obj }
  type                     = "egress"
  security_group_id        = aws_security_group.eks_cluster-node.id
  cidr_blocks              = each.value.cidrs
  protocol                 = "udp"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
}

resource "aws_security_group_rule" "eks_cluster-node-egress-tcp-dns" {
  for_each                 = { for index, obj in var.eks_worker_node_egress_tcp_dns : index => obj }
  type                     = "egress"
  security_group_id        = aws_security_group.eks_cluster-node.id
  cidr_blocks              = [each.value.from]
  protocol                 = "tcp"
  from_port                = each.value.port
  to_port                  = each.value.port
}

resource "aws_security_group_rule" "eks_cluster-node-egress-udp-dns" {
  for_each                 = { for index, obj in var.eks_worker_node_egress_udp_dns : index => obj }
  type                     = "egress"
  security_group_id        = aws_security_group.eks_cluster-node.id
  cidr_blocks              = [each.value.from]
  protocol                 = "udp"
  from_port                = each.value.port
  to_port                  = each.value.port
}

