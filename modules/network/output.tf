output "vpc_id" {
  value = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
}

output "public_subnet_ids" {
  value = [for sn in aws_subnet.public_subnets : sn.id]
}

output "private_subnet_ids" {
  value = [for sn in aws_subnet.private_subnets : sn.id]
}

output "private_subnet_sec_ids" {
  value = [for sn in aws_subnet.private_sec_subnets : sn.id]
}

output "private_elb_subnet_ids" {
  value = [for sn in aws_subnet.private_elb_subnets : sn.id]
}

output "vpc_endpoint_secgrp" {
  value = aws_security_group.vpc_endpoint
}