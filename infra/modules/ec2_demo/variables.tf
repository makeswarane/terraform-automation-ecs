variable "subnet_ids"        { type = list(string) }
variable "sg_id"             { type = string }
variable "instance_count"    { type = number }
variable "instance_type"     { type = string }
variable "target_group_arns" { type = map(string) }
variable "instance_port"     { type = number }
variable "docker_port"       { type = number }
variable "environment"       { type = string }