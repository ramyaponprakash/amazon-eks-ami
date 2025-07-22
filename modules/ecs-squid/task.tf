data "aws_iam_role" "ecs_task_execution_role" { name = "adex-u_ecs-role" }

resource "aws_ecs_task_definition" "adex_prd_solace_squid_task" {
  family                   = var.cluster_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name           = var.container_name
      image          = "704140326871.dkr.ecr.ap-southeast-1.amazonaws.com/sense_squid:alpine-solace",
      cpu            = 256,
      memory         = 512,
      essential      = true,
      environment    = [],
      mountPoints    = [],
      systemControls = [],
      volumesFrom    = [],
      healthcheck = {
        command  = ["CMD-SHELL", "echo 'healthy' || exit 1"],
        interval = 30,
        retries  = 3,
        timeout  = 5
      },
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-create-group  = "true",
          awslogs-group         = "ecs/adex-solace-ecs-squid",
          awslogs-region        = "ap-southeast-1",
          awslogs-stream-prefix = "fargate-squid"
        }
      },
      portMappings = [
        {
          name          = "3128",
          containerPort = 3128,
          hostPort      = 3128,
          protocol      = "tcp"
        },
        {
          name          = "healthcheck",
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        },
        {
          name          = "healthchecks",
          containerPort = 443,
          hostPort      = 443,
          protocol      = "tcp"
        }
      ],
      tags = {}
    }
  ])
}