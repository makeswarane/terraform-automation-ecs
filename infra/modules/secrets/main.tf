resource "aws_secretsmanager_secret" "db_secret" {
  # FINAL stable name - do not delete this from console once it exists
  name = "${var.environment}-db-creds-final"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_secret.arn
}
