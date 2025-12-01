output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_microservice_uri" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "rds_endpoint" {
  value = module.rds.endpoint
  description = "Empty if RDS disabled"
}
