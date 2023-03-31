resource "aws_eip" "solace_eip" {
  count = var.vpc_eip.enable_eip ? var.vpc_eip.count : 0
  vpc   = true
  tags = {
    Name = "${var.vpc_name}-eip"
  }
}
