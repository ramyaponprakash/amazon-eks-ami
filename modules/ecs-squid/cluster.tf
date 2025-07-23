resource "aws_ecs_cluster" "adex_prd_solace_squid_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}