resource "aws_security_group" "squidproxy" {
  name   = "${var.vpc_name}-squidproxy"
  vpc_id = var.vpc_id
  #description = "Allows traffic from and to the EC2 instances

  egress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["172.16.110.0/24"]
    description = "to prod squid"
  }

  egress {
    from_port   = 4122
    to_port     = 4122
    protocol    = "tcp"
    cidr_blocks = ["172.16.109.0/24"]
    description = "to dsm"
  }

  egress {
    from_port   = 4120
    to_port     = 4120
    protocol    = "tcp"
    cidr_blocks = ["172.16.109.0/24"]
    description = "to dsm"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-squidproxy"
  }
}

resource "aws_security_group_rule" "squidproxy-ingress-cidrs" {
  for_each          = { for index, obj in var.squid_secgrp_ingress_cidr : index => obj }
  type              = "ingress"
  description       = each.value.description
  security_group_id = aws_security_group.squidproxy.id
  cidr_blocks       = each.value.cidrs
  protocol          = "tcp"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
}

resource "aws_security_group_rule" "squidproxy-ingress-secgrp" {
  for_each                 = { for index, obj in var.squid_secgrp_ingress_secgrp : index => obj }
  type                     = "ingress"
  description              = each.value.description
  security_group_id        = aws_security_group.squidproxy.id
  source_security_group_id = each.value.secgrp_id
  protocol                 = "tcp"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
}