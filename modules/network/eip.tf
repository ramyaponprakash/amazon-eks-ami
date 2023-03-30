resource "aws_eip" "solace_eip" {
  count = var.eks_eip.enable_eip ? var.eks_eip.count : 0
  vpc   = true
  tags = {
    Name = "${var.vpc_name}-eip"
  }
}
