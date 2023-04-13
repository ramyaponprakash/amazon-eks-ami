resource "aws_security_group" "squidproxy" {
  name   = "${var.vpc_name}-squidproxy"
  vpc_id = var.vpc_id
  #description = "Allows traffic from and to the EC2 instances

  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["100.112.110.0/24", "100.80.27.128/26"]
    description = "from solx"
  }

  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["172.16.109.0/24"]
    description = "from mgmt"
  }
  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["10.193.135.128/28"]
    description = "from intra squid"
  }
  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["172.16.110.0/24"]
    description = "from NLB"
  }
  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["172.22.227.0/24"]
    description = "from nips"
  }
  ingress {
    from_port       = 3128
    to_port         = 3128
    protocol        = "tcp"
    security_groups = ["sg-02ad67e3edf285f26"]
    description     = "from panorama"
  }
  ingress {
    from_port       = 3128
    to_port         = 3128
    protocol        = "tcp"
    security_groups = ["sg-0ebf3f7e4a659286c"]
    description     = "from nips fw"
  }
  ingress {
    from_port       = 4118
    to_port         = 4118
    protocol        = "tcp"
    security_groups = ["sg-0e0678ca7fc5a3f73"]
    description     = "from dsm"
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-squidproxy"
  }
}

resource "aws_security_group" "ssh_squidproxy" {
  vpc_id      = var.vpc_id
  name        = "${var.vpc_name}-ssh-squidproxy"
  description = "from GCC ssh"

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = ["sg-0dd3d667f43ec5703"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-ssh-squidproxy"
  }
}