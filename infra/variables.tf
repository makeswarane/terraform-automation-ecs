variable "project" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "account_id" { type = string }

variable "domain" { type = string }

variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }

variable "acm_certificate_arn" { type = string }
variable "cluster_name" { type = string }

variable "ecs_instance_type" { type = string }
variable "ecs_instance_min" { type = number }
variable "ecs_instance_desired" { type = number }
variable "ecs_instance_max" { type = number }

variable "ecr_microservice_name" { type = string }
variable "microservice_container_port" { type = number }

variable "wordpress_image" { type = string }
variable "wordpress_container_port" { type = number }

variable "enable_rds" { type = bool }
variable "db_engine" { type = string }
variable "db_instance_class" { type = string }
variable "db_allocated_storage" { type = number }
variable "db_name" { type = string }
variable "db_username" { type = string }

variable "create_ec2_app" { type = bool }
variable "ec2_app_instance_type" { type = string }
variable "ec2_app_count" { type = number }

variable "tags" { type = map(string) default = {} }
