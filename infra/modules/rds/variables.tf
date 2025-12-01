variable "enable" { type = bool }
variable "db_engine" { type = string }
variable "db_instance_class" { type = string }
variable "db_allocated_storage" { type = number }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "subnet_ids" { type = list(string) }
variable "secret_arn" { type = string }
variable "project" { type = string default = "project" }
variable "environment" { type = string default = "env" }
variable "vpc_id" { type = string default = "" }
variable "vpc_cidr" { type = string default = "10.0.0.0/16" }
variable "skip_final_snapshot" { type = bool default = true }
variable "tags" { type = map(string) default = {} }
