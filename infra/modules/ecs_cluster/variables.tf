variable "cluster_name" { type = string }
variable "private_subnets" { type = list(string) }
variable "ecs_instance_type" { type = string }
variable "ecs_min" { type = number }
variable "ecs_desired" { type = number }
variable "ecs_max" { type = number }
variable "iam_instance_profile" { type = string }
variable "tags" { type = map(string) default = {} }
