variable "cluster_name" {}
variable "private_subnet_ids" { type = list(string) }
variable "ecr_repo" {}
variable "rds_endpoint" {}
variable "db_secret_arn" {}
variable "iam_task_role_arn" {}
variable "alb_sg_id" {}
variable "environment" { default = "dev" }
variable "region" { default = "ap-south-1" }
