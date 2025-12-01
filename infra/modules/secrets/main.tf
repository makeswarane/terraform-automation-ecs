resource "random_password" "db" {
  length = 16
  special = true
  override_characters = "!@#"
  keepers = { enabled = var.create_secret }
  depends_on = []
}

resource "aws_secretsmanager_secret" "db" {
  count = var.create_secret ? 1 : 0
  name = "${var.db_username}-db-credentials"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_version" {
  count = var.create_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.db[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
  })
}

output "secret_arn" {
  value = var.create_secret ? aws_secretsmanager_secret.db[0].arn : ""
}
