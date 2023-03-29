resource "aws_eip" "adex_prd_solace_eip" {
  tags = {
    Name = "adex-prd-solace-eip"
  }
}