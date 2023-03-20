#######################
# EKS post module with dynamic resource handling after cluster creation
#######################

module "eks_cluster_post" {
  source                = "./eks_post"
  cluster_name          = var.cluster_name
  environment           = var.environment
  default_nodegroup_asg = module.eks_cluster.default-nodegroup-asg
}