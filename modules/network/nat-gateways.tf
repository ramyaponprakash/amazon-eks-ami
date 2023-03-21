resource "aws_nat_gateway" "ngw" {
  count = length(var.vpc_nat_gw_eip_allocation_ids)

  allocation_id = var.vpc_nat_gw_eip_allocation_ids[count.index]
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "${var.vpc_name}-ngw-${var.az_map[count.index]}"
  }
}

data "aws_eip" "nat_gw_public_ips" {
  count = length(var.vpc_nat_gw_eip_allocation_ids)

  id = var.vpc_nat_gw_eip_allocation_ids[count.index]
}
