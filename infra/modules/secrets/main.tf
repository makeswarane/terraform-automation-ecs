resource "aws_secretsmanager_secret" "db_secret" {
  # Use a brand-new name; don't delete this one from console.
  name = "${var.environment}-db-creds-main"
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
