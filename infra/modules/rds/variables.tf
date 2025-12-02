variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_name" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}

variable "db_username" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "rds_security_group_id" {
  type = string
}

variable "backup_retention" {
  type = number
}

variable "skip_final_snapshot" {
  type = bool
}

variable "environment" {
  type    = string
  default = "dev"
}
