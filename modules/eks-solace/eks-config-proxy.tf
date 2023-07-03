resource "kubernetes_namespace" "solace-cloud" {
  metadata {
    annotations = {
      name = "solace-cloud"
    }
    name = "solace-cloud"
  }
}

resource "kubernetes_config_map" "proxy_configmap" {
  metadata {
    name      = "proxy-environment-variables"
    namespace = "solace-cloud"
  }

  data = {
    HTTP_PROXY  = var.eks_http_proxy
    HTTPS_PROXY = var.eks_http_proxy
    NO_PROXY    = "${join(",", data.aws_vpc.vpc.cidr_block_associations[*].cidr_block)},${data.aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr},${var.eks_default_no_proxy},${var.eks_private_ep_no_proxy}${var.eks_additional_no_proxy}"
  }
}
