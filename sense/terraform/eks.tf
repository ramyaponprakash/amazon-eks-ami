
#######################
# EKS module
#######################

module "eks_cluster" {
  source                        = "./eks"
  cluster_name                  = var.cluster_name
  cluster_vpc                   = var.cluster_vpc
  cluster_kms_key_arn           = var.cluster_kms_key_arn
  aws_account                   = var.aws_account
  sense_key                     = var.sense_key
  region                        = var.region
  cluster_log_retention_in_days = var.cluster_log_retention_in_days
  cluster_log_kms_key_id        = var.cluster_log_kms_key_id
  cluster_version               = var.cluster_version
  environment                   = var.environment
  instance_type                 = var.instance_type
  instance_type_bastion         = var.instance_type_bastion
  subnet_ids                    = var.subnet_ids
  subnet_id_bastion             = var.subnet_id_bastion
  endpoint_private_access       = var.endpoint_private_access
  endpoint_public_access        = var.endpoint_public_access
  eks_cw_loggroup               = var.eks_cw_loggroup
  bastion_ami                   = var.bastion_ami
  cidr_blocks_bastion_ssh       = var.cidr_blocks_bastion_ssh
  prefix_list_ids_bastion_ssh   = var.prefix_list_ids_bastion_ssh
  kubectl_version               = var.kubectl_version
  helm_version                  = var.helm_version
  helmfile_version              = var.helmfile_version
  kube_proxy_version            = var.kube_proxy_version
  vpc_cni_version               = var.vpc_cni_version
  coredns_version               = var.coredns_version
  cidr_blocks_additional_secgrp = var.cidr_blocks_additional_secgrp
}