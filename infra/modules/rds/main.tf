resource "aws_db_subnet_group" "db_subnets" {
  count = var.enable ? 1 : 0
  name = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags = var.tags
}

resource "aws_db_instance" "db" {
  count = var.enable ? 1 : 0
  allocated_storage    = var.db_allocated_storage
  engine               = var.db_engine
  instance_class       = var.db_instance_class
  name                 = var.db_name
  username             = var.db_username
  password             = local.password
  db_subnet_group_name = aws_db_subnet_group.db_subnets[0].name
  skip_final_snapshot  = var.skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  tags = var.tags
}

resource "aws_security_group" "db_sg" {
  count = var.enable ? 1 : 0
  name = "${var.project}-${var.environment}-db-sg"
  vpc_id = var.vpc_id
  description = "Database SG (private)"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
  tags = var.tags
}

locals {
  password = var.secret_arn != "" ? "RETRIEVE_FROM_SECRET_MANAGER" : random_password.generated[0].result
}

resource "random_password" "generated" {
  count = var.enable && var.secret_arn == "" ? 1 : 0
  length = 16
  special = true
}

output "endpoint" {
  value = var.enable ? aws_db_instance.db[0].address : ""
}
