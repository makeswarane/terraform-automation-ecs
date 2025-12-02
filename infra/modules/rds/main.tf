resource "aws_db_subnet_group" "this" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "wp" {
  identifier              = var.db_name
  allocated_storage       = var.db_allocated_storage
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class

  # ✅ Correct argument is db_name (not name) 
  db_name   = var.db_name
  username  = var.db_username
  password  = var.db_password

  db_subnet_group_name    = aws_db_subnet_group.this.name
  publicly_accessible     = false
  vpc_security_group_ids  = [var.rds_security_group_id]
  backup_retention_period = var.backup_retention
  skip_final_snapshot     = var.skip_final_snapshot
}

output "db_address" {
  value = aws_db_instance.wp.address
}

output "db_port" {
  value = aws_db_instance.wp.port
}
