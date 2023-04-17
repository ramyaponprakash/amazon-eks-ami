
data "aws_availability_zones" "available" {
  state         = "available"
  exclude_names = var.vpc_excluded_zone_names
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                  = "${var.cluster_name}-vpc"
  create_vpc            = var.network.create_vpc
  cidr                  = var.vpc_cidr_pri
  secondary_cidr_blocks = var.vpc_secondary_cidr_blocks
  azs                   = data.aws_availability_zones.available.names

  # One NAT Gateway per availability zone
  # NAT Gateways is created outside
  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true

  tags = {
    // NOTE: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
