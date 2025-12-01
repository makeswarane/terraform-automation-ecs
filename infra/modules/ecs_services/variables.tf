variable "cluster_name" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "ecr_repo_uri" { type = string }
variable "microservice_port" { type = number }
variable "wordpress_image" { type = string }
variable "wordpress_port" { type = number }
variable "secret_arn" { type = string }
variable "tags" { type = map(string) default = {} }
variable "task_role_arn" { type = string default = "" }
variable "aws_region" { type = string default = "" }
