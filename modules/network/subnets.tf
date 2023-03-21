// NOTE: https://repost.aws/knowledge-center/eks-vpc-subnet-discovery

resource "aws_subnet" "public_subnets" {
  count                   = length(var.vpc_public_subnets)
  vpc_id                  = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
  cidr_block              = var.vpc_public_subnets[count.index].cidr
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                                        = "${var.vpc_name}-public-sn-${var.az_map[count.index]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = var.vpc_public_subnets[count.index].enable_elb
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = length(var.vpc_private_subnets)
  vpc_id                  = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
  cidr_block              = var.vpc_private_subnets[count.index].cidr
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "${var.vpc_name}-private-sn-${var.az_map[count.index]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = var.vpc_private_subnets[count.index].enable_elb
  }
}

resource "aws_subnet" "private_elb_subnets" {
  count                   = length(var.vpc_private_elb_subnets)
  vpc_id                  = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
  cidr_block              = var.vpc_private_elb_subnets[count.index].cidr
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "${var.vpc_name}-private-elb-sn-${var.az_map[count.index]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = var.vpc_private_elb_subnets[count.index].enable_elb
  }
}