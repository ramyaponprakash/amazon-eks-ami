resource "kubernetes_annotations" "remove_default_storage_class" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
}

resource "kubernetes_storage_class" "gp2" {
  metadata {
    name = "gp2-default"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  parameters = {
    type      = "gp3"
    fsType    = "xfs"
    encrypted = "true"
    kmsKeyId  = var.eks_customer_cmk_key_arn != "" ? var.eks_customer_cmk_key_arn : null
  }
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"

  depends_on = [
    kubernetes_annotations.remove_default_storage_class,
    aws_eks_cluster.eks_cluster
  ]
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  parameters = {
    type      = "gp3"
    fsType    = "xfs"
    encrypted = "true"
    kmsKeyId  = var.eks_customer_cmk_key_arn != "" ? var.eks_customer_cmk_key_arn : null
  }
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}
