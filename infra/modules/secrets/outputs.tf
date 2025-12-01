output "secret_arn" {
  value = length(aws_secretsmanager_secret.db) > 0 ? aws_secretsmanager_secret.db[0].arn : ""
}
