resource "aws_internet_gateway" "igw" {
  count  = var.vpc_igw.enable_igw ? var.vpc_igw.count : 0
  vpc_id = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id

  tags = {
    Name = "${var.vpc_name}-vpc-igw"
  }
}