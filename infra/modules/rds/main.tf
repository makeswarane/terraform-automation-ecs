variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "db_name" {}
variable "db_instance_class" {}
variable "db_allocated_storage" {}
variable "db_username" {}
variable "db_secret_arn" {}
variable "rds_security_group_id" {}
variable "backup_retention" {}
variable "skip_final_snapshot" {}
variable "environment" { default = "dev" }

resource "aws_db_subnet_group" "this" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.private_subnet_ids
}

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = var.db_secret_arn
}

resource "aws_db_instance" "wp" {
  identifier              = "${var.db_name}"
  allocated_storage       = var.db_allocated_storage
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  name                    = var.db_name
  username                = var.db_username
  password                = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["password"]
  db_subnet_group_name    = aws_db_subnet_group.this.name
  publicly_accessible     = false
  vpc_security_group_ids  = [var.rds_security_group_id]
  backup_retention_period = var.backup_retention
  skip_final_snapshot     = var.skip_final_snapshot
}

output "db_address" { value = aws_db_instance.wp.address }
output "db_port"    { value = aws_db_instance.wp.port }
