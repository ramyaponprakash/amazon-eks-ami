resource "aws_lb" "squid_nlb" {

  name                             = "${var.vpc_name}-squid-nlb"
  internal                         = true
  subnets                          = [var.squid.subnet_gw_ids[0], var.squid.subnet_gw_ids[1]]
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

resource "aws_lb_listener" "squid_nlb_listener_3128" {
  load_balancer_arn = aws_lb.squid_nlb.arn
  port              = 3128
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.squid_target_group_3128.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "squid_target_group_3128" {
  name     = "${var.vpc_name}-squid-tg-3128"
  port     = 3128
  protocol = "TCP"
  vpc_id   = var.vpc_id
  health_check {
    protocol            = "TCP"
    port                = 3128
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
  }
}