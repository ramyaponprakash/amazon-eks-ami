terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
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

module "remote_state" {
  source = "../../modules/remote-state"
}

module "eks_network" {
  count  = var.network.enable ? 1 : 0
  source = "../../modules/network"

  network                       = var.network
  region                        = var.region
  cluster_name                  = var.cluster_name
  vpc_name                      = var.vpc_name
  vpc_cidr                      = var.vpc_cidr
  vpc_eip                       = var.vpc_eip
  vpc_nat_gateway               = var.vpc_nat_gateway
  vpc_igw                       = var.vpc_igw
  vpc_secondary_cidr_blocks     = var.vpc_secondary_cidr_blocks
  vpc_id                        = var.vpc_id
  vpc_nat_gw_eip_allocation_ids = var.vpc_nat_gw_eip_allocation_ids
  vpc_public_subnets            = var.vpc_public_subnets
  vpc_private_subnets           = var.vpc_private_subnets
  vpc_private_elb_subnets       = var.vpc_private_elb_subnets
}

module "bastion" {
  count  = var.bastion.enable ? 1 : 0
  source = "../../modules/bastion"

  region       = var.region
  cluster_name = var.cluster_name
  vpc_id       = var.network.enable ? module.eks_network[0].vpc_id : var.vpc_id

  bastion = merge(var.bastion, {
    subnet_ids      = var.network.enable ? (var.bastion.public_access ? module.eks_network[0].public_subnet_ids : module.eks_network[0].private_subnet_ids) : var.bastion.subnet_ids
    ssh_cidr_blocks = var.network.enable ? [var.vpc_cidr] : var.bastion.ssh_cidr_blocks
  })

  depends_on = [module.eks_network[0]]
}

module "eks" {
  source = "../../modules/eks"

  region       = var.region
  cluster_name = var.cluster_name
  vpc_id       = var.network.enable ? module.eks_network[0].vpc_id : var.bastion.vpc_id

  eks_private_subnet_ids    = var.network.enable ? module.eks_network[0].private_subnet_ids : var.eks_private_subnet_ids
  bastion_security_group_id = var.bastion.enable ? module.bastion[0].bastion_sg_id : var.bastion_security_group_id
  eks_customer_cmk_key_arn  = var.eks_customer_cmk_key_arn
  eks_admin_role_arns       = var.eks_admin_role_arns

  // NOTE: no need pub endpoint, just demo purpose
  eks_cluster_endpoint_public = var.eks_cluster_endpoint_public

  depends_on = [
    module.eks_network[0],
    module.bastion[0]
  ]
}

module "eks-solace" {
  source = "../../modules/eks-solace"

  cluster_name           = var.cluster_name
  eks_private_subnet_ids = var.network.enable ? module.eks_network[0].private_subnet_ids : var.eks_private_subnet_ids
  eks_node_role_arn      = module.eks.eks_node_role_arn
  eks_node_role_name     = module.eks.eks_node_role_name

  depends_on = [
    module.eks,
  ]
}

