output "alb_dns_name" { value = module.alb.alb_dns_name }
output "rds_endpoint" { value = module.rds.db_address }
output "ecr_repo_urls" { value = module.ecr.repo_urls }
output "ecs_cluster_name" { value = module.ecs_cluster.cluster_name }
output "ec2_app_instance_ids" { value = module.ec2_app.instance_ids }
