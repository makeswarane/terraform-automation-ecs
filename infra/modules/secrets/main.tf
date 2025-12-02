resource "aws_secretsmanager_secret" "db_secret" {
  # New unique name to avoid conflict with old "free-db-creds" that’s scheduled for deletion
  name = "${var.environment}-db-creds-v3"
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
