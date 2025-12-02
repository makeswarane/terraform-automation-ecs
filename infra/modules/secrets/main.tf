variable "db_username" {}
variable "db_password" {}
variable "environment" { default = "dev" }

resource "aws_secretsmanager_secret" "db_secret" {
  name = "${var.environment}-db-creds"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

output "db_secret_arn" { value = aws_secretsmanager_secret.db_secret.arn }
