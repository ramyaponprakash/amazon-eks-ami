// Security group for the nodes
resource "aws_security_group" "eks_cluster-node" {
  name        = "${var.cluster_name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.eks_worker_node_access_cidrs
    content {
      description = ingress.value.description
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidrs
      from_port   = ingress.value.port
      to_port     = ingress.value.port
    }
  }

  dynamic "ingress" {
    for_each = var.eks_worker_node_access_prefix
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      prefix_list_ids = ingress.value.prefix_list_ids
      from_port       = ingress.value.port
      to_port         = ingress.value.port
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

