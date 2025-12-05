############################################
# GLOBAL VARIABLES
############################################

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "domain_name" {
  description = "Root domain name (example: piedpipers.online)"
  type        = string
}

############################################
# NETWORK
############################################

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDR list"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR list"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

############################################
# ECS CLUSTER (EC2 LAUNCH TYPE)
############################################

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "dev-ecs"
}

variable "ecs_instance_type" {
  description = "Instance type for ECS EC2 nodes"
  type        = string
  default     = "t3.micro"
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

############################################
# EC2 Standalone Instances (Instance + Docker)
############################################

variable "ec2_demo_count" {
  description = "Number of EC2 demo servers"
  type        = number
  default     = 2
}

variable "ec2_demo_type" {
  description = "Instance type for demo EC2"
  type        = string
  default     = "t3.micro"
}

############################################
# RDS – WORDPRESS DATABASE
############################################

variable "db_name" {
  description = "WordPress DB name"
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "DB username"
  type        = string
  default     = "wpuser"
}

variable "db_password" {
  description = "DB password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

variable "db_allocated_storage" {
  description = "RDS storage"
  type        = number
  default     = 20
}

variable "backup_retention" {
  description = "Retention period"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip snapshot on destroy"
  type        = bool
  default     = false
}

############################################
# ALB / HTTPS
############################################

variable "alb_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}

############################################
# SERVICE PORTS
############################################

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
