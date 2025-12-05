##################################
# Secrets Manager for DB creds
##################################

resource "aws_secretsmanager_secret" "db_secret" {
  # Use name_prefix instead of fixed name.
  # Even if an old secret name is scheduled for deletion,
  # AWS will generate a new unique final name.
  name_prefix = "${var.environment}-db-creds-"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}
