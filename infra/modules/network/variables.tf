variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/free/prod)"
  type        = string
  default     = "dev"
}
