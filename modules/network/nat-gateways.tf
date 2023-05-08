resource "aws_nat_gateway" "ngw" {
  count         = var.vpc_nat_gateway.enable ? (var.vpc_eip.enable_eip ? length(aws_eip.vpc_eip) : length(var.vpc_nat_gateway.vpc_nat_gw_eip_allocation_ids)) : 0
  allocation_id = var.vpc_eip.enable_eip ? aws_eip.vpc_eip[count.index].allocation_id : var.vpc_nat_gateway.vpc_nat_gw_eip_allocation_ids[count.index]
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "${var.vpc_name}-ngw-${var.az_map[count.index % 3]}"
  }
}

data "aws_eip" "nat_gw_public_ips" {
  count = length(var.vpc_nat_gw_eip_allocation_ids)
  id    = var.vpc_nat_gw_eip_allocation_ids[count.index]
}