resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  version = var.k8s_master_version

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster-cluster.id, aws_security_group.eks_cluster-node.id]
    subnet_ids              = var.eks_private_subnet_ids
    endpoint_private_access = var.eks_cluster_endpoint_private
    endpoint_public_access  = var.eks_cluster_endpoint_public
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster-AmazonEKSServicePolicy,
  ]

  tags = {
    Name = var.cluster_name
  }

  lifecycle {
    ignore_changes = [version]
  }
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks_cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks_cluster.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1
      args:
      - --region
      - ${var.region}
      - eks
      - get-token
      - --cluster-name
      - ${var.cluster_name}
      command: aws
      interactiveMode: IfAvailable
KUBECONFIG

  ssh_kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: https://127.0.0.1:1212
    insecure-skip-tls-verify: true
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1
      args:
      - --region
      - ${var.region}
      - eks
      - get-token
      - --cluster-name
      - ${var.cluster_name}
      command: aws
      interactiveMode: IfAvailable
KUBECONFIG

}
