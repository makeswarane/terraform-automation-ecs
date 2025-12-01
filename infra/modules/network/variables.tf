variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "project" { type = string default = "project" }
variable "environment" { type = string default = "env" }
variable "tags" { type = map(string) default = {} }
