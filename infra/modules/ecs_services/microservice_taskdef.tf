resource "aws_cloudwatch_log_group" "microservice" {
  name = "/ecs/microservice"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "microservice" {
  family = "microservice"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  cpu = "256"
  memory = "512"
  task_role_arn = var.task_role_arn != "" ? var.task_role_arn : null
  container_definitions = jsonencode([{
    name = "microservice"
    image = var.ecr_repo_uri
    essential = true
    portMappings = [{ containerPort = var.microservice_port, hostPort = var.microservice_port }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = aws_cloudwatch_log_group.microservice.name
        awslogs-region = var.aws_region != "" ? var.aws_region : lookup(data.aws_region.current, "name", "us-east-1")
        awslogs-stream-prefix = "ecs"
      }
    }
    environment = [
      { name = "SERVICE_ENV", value = "prod" }
    ]
    secrets = var.secret_arn != "" ? [{ name = "DB_CREDENTIALS", valueFrom = var.secret_arn }] : []
  }])
}

data "aws_region" "current" {}
