terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--region", "ap-southeast-1", "--cluster-name", var.cluster_name]
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks_network" {
  count  = var.network.enable ? 1 : 0
  source = "../../modules/network"

  network                       = var.network
  vpc_enable_private            = var.vpc_enable_private
  vpc_endpoint_allowed_cidrs    = var.vpc_endpoint_allowed_cidrs
  vpc_endpoint_subnets          = var.vpc_endpoint_subnets
  vpc_eip                       = var.vpc_eip
  vpc_nat_gateway               = var.vpc_nat_gateway
  vpc_igw                       = var.vpc_igw
  vpc_nat_gw_ids                = var.vpc_nat_gw_ids
  vpc_igw_ids                   = var.vpc_igw_ids
  region                        = var.region
  cluster_name                  = var.cluster_name
  vpc_name                      = var.vpc_name
  vpc_cidr_pri                  = var.vpc_cidr_pri
  vpc_cidr_sec                  = var.vpc_cidr_sec
  vpc_secondary_cidr_blocks     = var.vpc_secondary_cidr_blocks
  vpc_id                        = var.vpc_id
  vpc_nat_gw_eip_allocation_ids = var.vpc_nat_gw_eip_allocation_ids
  vpc_public_subnets            = var.vpc_public_subnets
  vpc_private_subnets           = var.vpc_private_subnets
  vpc_private_elb_subnets       = var.vpc_private_elb_subnets
  gcc_vpc_tags                  = var.gcc_vpc_tags
}

module "bastion" {
  count  = var.bastion.enable ? 1 : 0
  source = "../../modules/bastion"

  region       = var.region
  account_id   = var.account_id
  cluster_name = var.cluster_name
  vpc_id       = var.network.enable ? module.eks_network[0].vpc_id : var.vpc_id

  bastion_secgrp_ingress_cidr        = var.bastion_secgrp_ingress_cidr
  bastion_secgrp_ingress_prefix_list = var.bastion_secgrp_ingress_prefix_list
  bastion_secgrp_ingress_secgrp      = var.bastion_secgrp_ingress_secgrp

  bastion = merge(var.bastion, {
    subnet_ids = var.network.enable ? (var.bastion.public_access ? module.eks_network[0].public_subnet_ids : module.eks_network[0].private_subnet_ids) : var.bastion.subnet_ids
  })
}

module "eks" {
  source = "../../modules/eks"

  region                              = var.region
  account_id                          = var.account_id
  cluster_name                        = var.cluster_name
  vpc_id                              = var.network.enable ? module.eks_network[0].vpc_id : var.vpc_id
  eks_private_subnet_ids              = var.network.enable ? module.eks_network[0].private_subnet_ids : var.eks_private_subnet_ids
  eks_customer_cmk_key_arn            = var.eks_customer_cmk_key_arn
  eks_admin_role_arns                 = concat(var.eks_admin_role_arns, [module.bastion[0].bastion-iam_role_arn])
  eks_http_proxy                      = var.eks_http_proxy
  eks_api_endpoint_access_cidrs       = var.eks_api_endpoint_access_cidrs
  eks_cluster_egress_access_cidrs     = var.eks_cluster_egress_access_cidrs
  eks_worker_node_egress_tcp_HA       = var.eks_worker_node_egress_tcp_HA
  eks_eks_worker_node_egress_udp_HA   = var.eks_worker_node_egress_udp_HA
  eks_eks_worker_node_egress_tcp_dns  = var.eks_worker_node_egress_tcp_dns
  eks_worker_node_egress_udp_dns      = var.eks_worker_node_egress_udp_dns
  eks_worker_node_egress_access_cidrs = var.eks_worker_node_egress_access_cidrs 
  eks_worker_node_access_cidrs        = var.eks_worker_node_access_cidrs
  eks_worker_node_access_prefix       = var.eks_worker_node_access_prefix
}

module "eks-solace" {
  source = "../../modules/eks-solace"

  cluster_name           = var.cluster_name
  vpc_id                 = var.network.enable ? module.eks_network[0].vpc_id : var.bastion.vpc_id
  eks_private_subnet_ids = var.network.enable ? module.eks_network[0].private_subnet_ids : var.eks_private_subnet_ids
  eks_node_role_arn      = module.eks.eks_node_role_arn
  eks_node_role_name     = module.eks.eks_node_role_name
  eks_http_proxy         = var.eks_http_proxy
  cluster_node_secgrp_id = module.eks.cluster_node_secgrp_id

  depends_on = [
    module.eks,
  ]
}
