# infra/modules/ecs_services/main.tf

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.environment}"
  retention_in_days = 7
}

# === WordPress Task Definition ===
resource "aws_ecs_task_definition" "wordpress" {
  family                   = "${var.environment}-wordpress"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "wordpress"
    image     = "wordpress:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = var.wordpress_port
      protocol      = "tcp"
    }]
    environment = [
      { name = "WORDPRESS_DB_HOST", value = var.rds_endpoint },
      { name = "WORDPRESS_DB_USER", value = "wpadmin" },
      { name = "WORDPRESS_DB_NAME", value = "wordpress" }
    ]
    secrets = [{
      name      = "WORDPRESS_DB_PASSWORD"
      valueFrom = "${var.db_secret_arn}:password::"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "wordpress"
      }
    }
  }])
}

# === Microservice Task Definition ===
resource "aws_ecs_task_definition" "microservice" {
  family                   = "${var.environment}-microservice"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([{
    name      = "microservice"
    image     = "${var.ecr_repo_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = var.microservice_port
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "microservice"
      }
    }
  }])
}

# IAM Roles for ECS Tasks
resource "aws_iam_role" "ecs_execution" {
  name = "${var.environment}-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.environment}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "secrets" {
  name = "${var.environment}-secrets-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = var.db_secret_arn
    }]
  })
}

# ECS Services
resource "aws_ecs_service" "wordpress" {
  name            = "wordpress"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = var.alb_target_group_arns.wordpress
    container_name   = "wordpress"
    container_port   = 80
  }
}

resource "aws_ecs_service" "microservice" {
  name            = "microservice"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.microservice.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = var.alb_target_group_arns.microservice
    container_name   = "microservice"
    container_port   = 3000
  }
}