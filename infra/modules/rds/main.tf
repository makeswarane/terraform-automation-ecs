# infra/modules/rds/main.tf
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "rds" {
  name   = "${var.environment}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.private_sg_id]
  }
}

resource "aws_db_instance" "main" {
  identifier              = "${var.environment}-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  allocated_storage       = var.allocated_storage
  db_name                 = "wordpress"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  publicly_accessible     = false
  backup_retention_period = var.backup_retention
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = "${var.environment}-final-snapshot"
  storage_encrypted       = true
  multi_az                = false
  apply_immediately       = true
}