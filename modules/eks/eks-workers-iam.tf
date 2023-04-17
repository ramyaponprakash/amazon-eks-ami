// https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html

resource "aws_iam_role" "eks_cluster-node" {
  name = "${var.cluster_name}-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.${data.aws_partition.this.dns_suffix}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_cluster-node.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_cluster-node.name
}

// IPv4
resource "aws_iam_role_policy_attachment" "eks_cluster-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_cluster-node.name
}

resource "aws_iam_instance_profile" "eks_cluster-node" {
  name = "${var.cluster_name}-profile"
  role = aws_iam_role.eks_cluster-node.name
}
