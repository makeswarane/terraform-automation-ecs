output "service_map" { value = { wordpress = aws_ecs_service.wordpress.name, microservice = aws_ecs_service.microservice.name } }
