# Deploys an OpenID Connect provider to be used by the EKS Cluster.  This is required by IAM For Service Account.
# It allows assigning IAM Roles directly to pods via Service Accounts instead of via an instance profile which ends
# up accessible to just any pods in a cluster.

# This will be used by the autoscaler and the AWS LB Controller

data "tls_certificate" "eks_oidc_issuer" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_issuer.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}
