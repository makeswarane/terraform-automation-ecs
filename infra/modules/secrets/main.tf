# infra/modules/secrets/main.tf
resource "random_password" "db" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.environment}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    engine   = "mysql"
    host     = var.rds_endpoint
    port     = 3306
    dbname   = "wordpress"
  })
}