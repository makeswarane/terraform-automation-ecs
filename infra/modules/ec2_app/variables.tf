variable "private_sg_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "iam_instance_profile" { type = string }
variable "domain" {}
variable "instance_count" { default = 2 }
variable "ec2_instance_type" { default = "t3.micro" }
variable "environment" { default = "dev" }
