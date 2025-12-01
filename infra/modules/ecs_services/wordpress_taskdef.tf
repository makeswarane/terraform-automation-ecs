resource "aws_cloudwatch_log_group" "wordpress" {
  name = "/ecs/wordpress"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "wordpress" {
  family = "wordpress"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  cpu = "512"
  memory = "1024"
  container_definitions = jsonencode([{
    name = "wordpress"
    image = var.wordpress_image
    essential = true
    portMappings = [{ containerPort = var.wordpress_port, hostPort = var.wordpress_port }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = aws_cloudwatch_log_group.wordpress.name
        awslogs-region = var.aws_region != "" ? var.aws_region : lookup(data.aws_region.current, "name", "us-east-1")
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

data "aws_region" "current" {}
