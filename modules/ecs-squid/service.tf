resource "aws_ecs_service" "adex_prd_solace_squid_service" {
  name            = "adex-ecs-prd-solace-squid-service"
  cluster         = aws_ecs_cluster.adex_prd_solace_squid_cluster.id
  task_definition = aws_ecs_task_definition.adex_prd_solace_squid_task.arn
  desired_count   = var.number_replicas
  launch_type     = "FARGATE"
  scheduling_strategy = "REPLICA"
  enable_execute_command = true
  depends_on = [ aws_ecs_task_definition.adex_prd_solace_squid_task ]
  # This block registers the tasks to a target group of the loadbalancer.
  load_balancer {
    target_group_arn                    = var.nlb_ecs_tg_arn
    container_name                      = var.container_name
    container_port                      = var.squid_port
  }

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.solace_subnets
  }
}