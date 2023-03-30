resource "aws_route_table" "public" {
  count  = length(var.vpc_igw_ids)
  vpc_id = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.vpc_igw.enable_igw ? aws_internet_gateway.igw[count.index].id : var.vpc_igw_ids[count.index]
  }

  tags = {
    Name = "${var.vpc_name}-rt-public-${var.az_map[count.index]}"
  }
}


resource "aws_route_table_association" "pub" {
  count          = length(var.vpc_igw_ids)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}


resource "aws_route_table" "private" {
  count  = length(var.vpc_nat_gw_ids)
  vpc_id = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.vpc_nat_gateway.enable ? aws_nat_gateway.ngw[count.index % length(aws_nat_gateway.ngw)].id : var.vpc_nat_gw_ids[count.index]
  }

  tags = {
    Name = "${var.vpc_name}-rt-private-${var.az_map[count.index]}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.vpc_nat_gw_ids)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "private_nlb" {
  count = length(var.vpc_private_elb_subnets) > 0 ? 1 : 0

  vpc_id = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id

  tags = {
    Name = "${var.vpc_name}-rt-private-nlb-${var.az_map[count.index]}"
  }
}

resource "aws_route_table_association" "private_nlb" {
  count          = length(aws_subnet.private_elb_subnets)
  subnet_id      = aws_subnet.private_elb_subnets[count.index].id
  route_table_id = aws_route_table.private_nlb[0].id
}