resource "kubernetes_config_map" "proxy_configmap" {
  metadata {
    name      = "proxy-environment-variables"
    namespace = "kube-system"
  }

  data = {
    HTTP_PROXY  = var.eks_http_proxy
    HTTPS_PROXY = var.eks_http_proxy
    NO_PROXY    = "${join(",", data.aws_vpc.vpc.cidr_block_associations[*].cidr_block)},${aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr},${var.eks_default_no_proxy},${var.eks_private_ep_no_proxy}${var.eks_additional_no_proxy}"
  }
}


# NOTE: currently "kubernetes_config_map" expect to be run in host where can access eks API endpoint
#       alternatively will use /cicd/sol-init.sh until we finalise CICD pipeline
#resource "kubernetes_manifest" "aws_node_patch" {
#  manifest = {
#    apiVersion = "apps/v1"
#    kind       = "DaemonSet"
#    metadata = {
#      name      = "aws-node"
#      namespace = "kube-system"
#    }
#    spec = {
#      template = {
#        spec = {
#          containers = [
#            {
#              name = "aws-node"
#              envFrom = [
#                {
#                  configMapRef = {
#                    name = "proxy-environment-variables"
#                  }
#                }
#              ]
#            }
#          ]
#        }
#      }
#    }
#  }
#
#  depends_on = [
#    kubernetes_config_map.proxy_configmap
#  ]
#}
#
#resource "kubernetes_manifest" "kube_proxy_patch" {
#  manifest = {
#    apiVersion = "apps/v1"
#    kind       = "DaemonSet"
#    metadata = {
#      name      = "kube-proxy"
#      namespace = "kube-system"
#    }
#    spec = {
#      template = {
#        spec = {
#          containers = [
#            {
#              name = "kube-proxy"
#              envFrom = [
#                {
#                  configMapRef = {
#                    name = "proxy-environment-variables"
#                  }
#                }
#              ]
#            }
#          ]
#        }
#      }
#    }
#  }
#
#  depends_on = [
#    kubernetes_config_map.proxy_configmap
#  ]
#}