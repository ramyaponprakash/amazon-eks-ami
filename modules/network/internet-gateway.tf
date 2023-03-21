resource "aws_internet_gateway" "igw" {
  vpc_id = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id

  tags = {
    Name = "${var.vpc_name}-vpc-igw"
  }
}