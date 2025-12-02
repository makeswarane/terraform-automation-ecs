variable "public_subnet_ids" { type = list(string) }
variable "alb_certificate_arn" {}
variable "domain" {}
variable "tg_wordpress_arn" {}
variable "tg_micro_arn" {}
variable "ec2_instance_ids" { type = list(string) }
variable "ec2_docker_ids" { type = list(string) }
variable "alb_sg_id" {}
variable "environment" { default = "dev" }
