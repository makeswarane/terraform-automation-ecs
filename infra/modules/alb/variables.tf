variable "vpc_id" { type = string }
variable "public_subnets" { type = list(string) }
variable "domain" { type = string }
variable "acm_certificate_arn" { type = string }
variable "tags" { type = map(string) default = {} }
variable "wordpress_port" { type = number default = 80 }
variable "microservice_port" { type = number default = 3000 }
variable "services" { type = map(string) default = {} }
