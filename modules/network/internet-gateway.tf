resource "aws_internet_gateway" "igw" {
  count  = var.eks_igw.enable_igw ? var.eks_igw.count : 0
  vpc_id = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id

  tags = {
    Name = "${var.vpc_name}-vpc-igw"
  }
}