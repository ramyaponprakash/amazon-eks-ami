#############################
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#############################

resource "aws_iam_role" "sdx-eks-cluster" {
  name = "role-${var.cluster_name}-cluster"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${var.aws_account}:user/eks",
                    "arn:aws:iam::${var.aws_account}:root",
                    "arn:aws:iam::726262972162:root"
                ],
                "Service": [
                    "eks.amazonaws.com",
                    "eks-fargate-pods.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "sdx-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.sdx-eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "sdx-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.sdx-eks-cluster.name
}

#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#

resource "aws_iam_role" "sdx-eks-node" {
  name = "role-${var.cluster_name}-node"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com",
                "AWS": [
                    "arn:aws:iam::${var.aws_account}:user/eks",
                    "arn:aws:iam::726262972162:root",
                    "arn:aws:iam::${var.aws_account}:root"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "sdx-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.sdx-eks-node.name
}

resource "aws_iam_role_policy_attachment" "sdx-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.sdx-eks-node.name
}

resource "aws_iam_role_policy_attachment" "sdx-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.sdx-eks-node.name
}