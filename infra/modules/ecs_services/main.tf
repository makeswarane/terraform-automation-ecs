variable "cluster_name" {}
variable "private_subnet_ids" { type = list(string) }
variable "ecr_repo" {}
variable "rds_endpoint" {}
variable "db_secret_arn" {}
variable "iam_task_role_arn" {}
variable "alb_sg_id" {}
variable "environment" { default = "dev" }
variable "region" { default = "ap-south-1" }

resource "aws_cloudwatch_log_group" "wordpress" { name = "/ecs/wordpress" retention_in_days = 14 }
resource "aws_cloudwatch_log_group" "micro" { name = "/ecs/microservice" retention_in_days = 14 }

resource "aws_lb_target_group" "wordpress" {
  name = "tg-wordpress"
  port = 8080
  protocol = "HTTP"
  target_type = "instance"
  health_check { path = "/" interval = 30 healthy_threshold = 2 unhealthy_threshold = 3 matcher = "200-399" }
}

resource "aws_lb_target_group" "micro" {
  name = "tg-microservice"
  port = 3000
  protocol = "HTTP"
  target_type = "instance"
  health_check { path = "/" interval = 30 healthy_threshold = 2 unhealthy_threshold = 3 matcher = "200-399" }
}

resource "aws_ecs_task_definition" "wordpress" {
  family = "wordpress"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  cpu = "512"
  memory = "1024"
  execution_role_arn = var.iam_task_role_arn
  task_role_arn = var.iam_task_role_arn

  container_definitions = jsonencode([
    {
      name = "wordpress"
      image = "wordpress:php8.0-apache"
      essential = true
      portMappings = [{ containerPort = 80, hostPort = 8080 }]
      environment = [
        { name = "WORDPRESS_DB_HOST", value = var.rds_endpoint },
        { name = "WORDPRESS_DB_NAME", value = "wordpress" },
        { name = "WORDPRESS_DB_USER", value = "wpuser" }
      ]
      secrets = [{ name = "WORDPRESS_DB_PASSWORD", valueFrom = var.db_secret_arn }]
      logConfiguration = {
        logDriver = "awslogs"
        options = { awslogs-group = aws_cloudwatch_log_group.wordpress.name, awslogs-region = var.region, awslogs-stream-prefix = "wordpress" }
      }
    }
  ])
}

resource "aws_ecs_service" "wordpress" {
  name = "wordpress"
  cluster = var.cluster_name
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count = 1
  launch_type = "EC2"
  load_balancer {
    target_group_arn = aws_lb_target_group.wordpress.arn
    container_name = "wordpress"
    container_port = 80
  }
}

resource "aws_ecs_task_definition" "micro" {
  family = "microservice"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  cpu = "256"
  memory = "512"
  execution_role_arn = var.iam_task_role_arn
  task_role_arn = var.iam_task_role_arn

  container_definitions = jsonencode([
    {
      name = "micro"
      image = var.ecr_repo
      essential = true
      portMappings = [{ containerPort = 3000, hostPort = 3000 }]
      logConfiguration = {
        logDriver = "awslogs"
        options = { awslogs-group = aws_cloudwatch_log_group.micro.name, awslogs-region = var.region, awslogs-stream-prefix = "micro" }
      }
    }
  ])
}

resource "aws_ecs_service" "micro" {
  name = "microservice"
  cluster = var.cluster_name
  task_definition = aws_ecs_task_definition.micro.arn
  desired_count = 1
  launch_type = "EC2"
  load_balancer {
    target_group_arn = aws_lb_target_group.micro.arn
    container_name = "micro"
    container_port = 3000
  }
}

output "tg_wordpress_arn" { value = aws_lb_target_group.wordpress.arn }
output "tg_micro_arn" { value = aws_lb_target_group.micro.arn }
output "tg_wordpress_name" { value = aws_lb_target_group.wordpress.name }
output "tg_micro_name" { value = aws_lb_target_group.micro.name }
