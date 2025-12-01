variable "region"               { type = string }
variable "environment"          { type = string }
variable "domain_name"          { type = string }
variable "acm_certificate_arn"  { type = string }

variable "vpc_cidr"             { type = string }
variable "public_subnets"       { type = list(string) }
variable "private_subnets"      { type = list(string) }

variable "ecs_cluster_name"     { type = string }
variable "ecs_instance_type"    { type = string }
variable "ecs_min_size"         { type = number }
variable "ecs_max_size"         { type = number }
variable "ecs_desired_capacity" { type = number }

variable "db_name"              { type = string }
variable "db_instance_class"    { type = string }
variable "db_allocated_storage" { type = number }
variable "db_username"          { type = string }
variable "db_password"          { type = string }
variable "backup_retention"     { type = number }
variable "skip_final_snapshot"  { type = bool }

variable "ec2_demo_count"       { type = number }
variable "ec2_demo_type"        { type = string }

variable "wordpress_port"       { type = number }
variable "microservice_port"    { type = number }
variable "instance_port"        { type = number }
variable "docker_port"          { type = number }

variable "ecs_cluster_name"     { type = string }
variable "ec2_demo_count"       { type = number }
variable "ec2_demo_type"        { type = string }
variable "region"               { type = string }