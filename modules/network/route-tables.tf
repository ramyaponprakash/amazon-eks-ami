resource "aws_route_table" "public" {
  count  = length(var.vpc_public_subnets)
  vpc_id = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.vpc_igw.enable_igw ? aws_internet_gateway.igw[0].id : var.vpc_igw_ids[0]
  }

  tags = {
    Name = "${var.vpc_name}-rt-public-${var.az_map[count.index % 3]}"
  }
}


resource "aws_route_table_association" "pub" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}


resource "aws_route_table" "private" {
  count  = length(aws_subnet.private_subnets)
  vpc_id = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id

  dynamic "route" {
    for_each = var.network.peers
    content {
      cidr_block                = route.value.destination
      vpc_peering_connection_id = route.value.target
    }
  }

  dynamic "route" {
    for_each = var.network.tgw
    content {
      cidr_block         = route.value.destination
      transit_gateway_id = route.value.target
    }
  }

  tags = {
    Name = "${var.vpc_name}-rt-private-${count.index + 1}-${var.az_map[count.index % length(data.aws_availability_zones.available.zone_ids)]}"
  }
}

// var.vpc_enable_private=true will rely on VPC Endpoint
resource "aws_route" "private_route_nat" {
  count                  = var.vpc_enable_private ? 0 : length(aws_subnet.private_subnets)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.vpc_nat_gateway.enable ? aws_nat_gateway.ngw[count.index % length(aws_nat_gateway.ngw)].id : var.vpc_nat_gw_ids[count.index % length(var.vpc_nat_gw_ids)]
  depends_on             = [aws_route_table.private]
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "private_nlb" {
  count = length(var.vpc_private_elb_subnets) > 0 ? 1 : 0

  vpc_id = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id

  tags = {
    Name = "${var.vpc_name}-rt-private-nlb-${var.az_map[count.index % 3]}"
  }
}

resource "aws_route_table_association" "private_nlb" {
  count          = length(aws_subnet.private_elb_subnets)
  subnet_id      = aws_subnet.private_elb_subnets[count.index].id
  route_table_id = aws_route_table.private_nlb[0].id
}