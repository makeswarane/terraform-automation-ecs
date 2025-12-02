variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_certificate_arn" {
  type = string
}

variable "domain" {
  type = string
}

variable "tg_wordpress_arn" {
  type = string
}

variable "tg_micro_arn" {
  type = string
}

variable "ec2_instance_ids" {
  type = list(string)
}

variable "ec2_docker_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}
