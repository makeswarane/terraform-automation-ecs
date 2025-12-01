resource "aws_ecs_service" "microservice" {
  name = "microservice"
  cluster = var.cluster_name
  task_definition = aws_ecs_task_definition.microservice.arn
  desired_count = 1
  launch_type = "EC2"
}

resource "aws_ecs_service" "wordpress" {
  name = "wordpress"
  cluster = var.cluster_name
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count = 1
  launch_type = "EC2"
}

output "service_map" {
  value = {
    wordpress = aws_ecs_service.wordpress.name
    microservice = aws_ecs_service.microservice.name
  }
}
