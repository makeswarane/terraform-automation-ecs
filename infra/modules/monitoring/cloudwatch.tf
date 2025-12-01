resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/all-services"
  retention_in_days = 14
}
output "log_group" { value = aws_cloudwatch_log_group.ecs.name }
