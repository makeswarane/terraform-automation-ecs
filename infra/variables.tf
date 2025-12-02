variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "account_id" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "domain_name" {
  type        = string
  description = "Your domain (e.g., piedpipers.online)"
}

# Network
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24","10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24","10.0.11.0/24"]
}

# ECS Cluster
variable "ecs_cluster_name" {
  type    = string
  default = "dev-ecs"
}

variable "ecs_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ecs_min_size" {
  type    = number
  default = 1
}

variable "ecs_max_size" {
  type    = number
  default = 2
}

variable "ecs_desired_capacity" {
  type    = number
  default = 1
}

# EC2 demo instances
variable "ec2_demo_count" {
  type    = number
  default = 2
}

variable "ec2_demo_type" {
  type    = string
  default = "t3.micro"
}

# RDS
variable "db_name" {
  type    = string
  default = "wordpress"
}

variable "db_username" {
  type    = string
  default = "wpuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.small"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "backup_retention" {
  type    = number
  default = 7
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}

# ALB / ACM
variable "alb_certificate_arn" {
  type        = string
  description = "ACM cert ARN for domain"
  default     = ""
}

# (Optional) Ports – currently not fully wired
variable "wordpress_port" {
  type    = number
  default = 8081
}

variable "microservice_port" {
  type    = number
  default = 3000
}

variable "instance_port" {
  type    = number
  default = 8000
}

variable "docker_port" {
  type    = number
  default = 8080
}
