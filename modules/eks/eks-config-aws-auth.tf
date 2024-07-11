locals {
  creator_role = data.aws_caller_identity.this.arn

  // default node role will be included.
  eks_node_group_iam_role_arns = concat([aws_iam_role.eks_cluster-node.arn], var.eks_node_group_iam_role_arns)

  node_group_iam_access = length(local.eks_node_group_iam_role_arns) != 0 ? [
    for key, arn in local.eks_node_group_iam_role_arns : {
      rolearn : arn
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ] : []

  admin_iam_access = length(var.eks_admin_role_arns) > 0 ? [
    for key, arn in var.eks_admin_role_arns : {
      rolearn : arn
      username : "admin_${key}"
      groups : [
        "system:masters"
      ]
    }
  ] : []
}

resource "kubernetes_config_map" "aws_auth_configmap" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    api_host = join("/", [data.aws_eks_cluster.cluster.endpoint])
    mapRoles = yamlencode(
      distinct(concat(
        local.node_group_iam_access,
        local.admin_iam_access,
      ))
    )
  }
  lifecycle {
    ignore_changes        = all
  }
}
