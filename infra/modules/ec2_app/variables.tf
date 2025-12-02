variable "private_sg_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "iam_instance_profile" {
  type = string
}

variable "domain" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "environment" {
  type    = string
  default = "dev"
}
