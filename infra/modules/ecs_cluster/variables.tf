variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids"  { type = list(string) }

variable "ecs_instance_type" {}
variable "ecs_min_size" {}
variable "ecs_max_size" {}
variable "ecs_desired_capacity" {}

variable "iam_instance_profile" {}
variable "cluster_name" {}
variable "region" {}
variable "environment" { default = "dev" }
