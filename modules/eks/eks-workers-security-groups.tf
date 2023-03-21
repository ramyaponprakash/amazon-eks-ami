// Security group for the nodes
resource "aws_security_group" "eks_cluster-node" {
  name        = "${var.cluster_name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
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

// This is to allow access from the bastion host
resource "aws_security_group_rule" "eks_cluster-node-bastion" {
  description              = "Allow ssh access from the bastion host"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster-node.id
  source_security_group_id = var.bastion_security_group_id
  type                     = "ingress"
}
