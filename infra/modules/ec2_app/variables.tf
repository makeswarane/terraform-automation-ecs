variable "create" { type = bool }
variable "count" { type = number }
variable "instance_type" { type = string }
variable "private_subnets" { type = list(string) }
variable "project" { type = string default = "project" }
variable "environment" { type = string default = "env" }
variable "vpc_id" { type = string default = "" }
variable "vpc_cidr" { type = string default = "10.0.0.0/16" }
variable "app_port" { type = number default = 8080 }
variable "tags" { type = map(string) default = {} }
variable "domain" { type = string default = "" }
