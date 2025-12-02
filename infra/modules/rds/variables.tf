variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }

variable "db_name" {}
variable "db_instance_class" {}
variable "db_allocated_storage" { default = 20 }

variable "db_username" {}
variable "db_secret_arn" {}
variable "rds_security_group_id" {}
variable "backup_retention" { default = 7 }
variable "skip_final_snapshot" { default = false }

variable "environment" { default = "dev" }
