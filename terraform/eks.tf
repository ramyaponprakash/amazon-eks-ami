
#######################
# EKS module
#######################

module "eks_cluster" {
  source                        = "./eks"
  cluster_name                  = var.cluster_name
  sense_vpc                     = var.sense_vpc 
  aws_account                   = var.aws_account
  sense_key                     = var.sense_key
  cluster_log_retention_in_days = var.cluster_log_retention_in_days
  cluster_version               = var.cluster_version
  environment                   = var.environment
  instance_type                 = var.instance_type
  instance_type_bastion         = var.instance_type_bastion
  subnet_ids                    = var.subnet_ids
  subnet_id_bastion             = var.subnet_id_bastion
  eks_cw_loggroup               = var.eks_cw_loggroup
  ami                           = var.ami
  cidr_blocks_bastion_ssh       = var.cidr_blocks_bastion_ssh
  prefix_list_ids_bastion_ssh   = var.prefix_list_ids_bastion_ssh

}