module "eks_cluster" {
  source                        = "./eks/"
  cluster_name                  = var.cluster_name
  sense_vpc                     = var.sense_vpc 
  aws_account                   = var.aws_account
  sense_key                     = var.sense_key
  cluster_log_retention_in_days = var.cluster_log_retention_in_days
  cluster_version               = var.cluster_version
  environment                   = var.environment
  instance_type                 = var.instance_type
  eks_cluster_subnet_ids        = var.eks_cluster_subnet_ids
  eks_nodegroup_subnet_ids      = var.eks_nodegroup_subnet_ids
  eks_cw_loggroup               = var.eks_cw_loggroup

}