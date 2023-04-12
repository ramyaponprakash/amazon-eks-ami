resource "aws_lb" "squid_nlb" {

  name                             = "${var.vpc_name}-squid-nlb"
  internal                         = true
  subnets                          = [var.squid.subnet_ids[0].cidr, var.squid.subnet_ids[1].cidr]
  load_balancer_type               = "network"
  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = "true"

  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name                = "${var.vpc_name}-squid-nlb"
    propagate_at_launch = true
  }
}