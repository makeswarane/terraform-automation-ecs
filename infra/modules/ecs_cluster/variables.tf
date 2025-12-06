variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "ecs_instance_type" {
  type = string
}

variable "ecs_min_size" {
  type = number
}

variable "ecs_max_size" {
  type = number
}

variable "ecs_desired_capacity" {
  type = number
}

variable "iam_instance_profile" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_sg_id" {
  type = string
}
