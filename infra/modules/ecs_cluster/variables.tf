variable "cluster_name"        { type = string }
variable "instance_type"       { type = string }
variable "min_size"            { type = number }
variable "max_size"            { type = number }
variable "desired_capacity"    { type = number }
variable "private_subnet_ids"  { type = list(string) }
variable "ecs_sg_id"           { type = string }
variable "environment"         { type = string }