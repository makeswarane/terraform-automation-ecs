#output "cluster_id"   { value = aws_ecs_cluster.main.id }
#output "cluster_name" { value = aws_ecs_cluster.main.name }
##############################
# ECS Cluster Module Outputs
##############################

# Expose the ECS cluster name to the root module
output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

# (Optional) – can be useful for debugging / info

output "asg_name" {
  description = "Name of the ECS Auto Scaling Group for ECS EC2 instances"
  value       = aws_autoscaling_group.ecs_asg.name
}

output "launch_template_id" {
  description = "ID of the launch template used by ECS EC2 instances"
  value       = aws_launch_template.ecs.id
}
