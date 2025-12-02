variable "cluster_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecr_repo" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "iam_task_role_arn" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "ap-south-1"
}
