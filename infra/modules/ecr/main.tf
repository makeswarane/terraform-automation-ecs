variable "repo_names" { type = list(string) }

resource "aws_ecr_repository" "repos" {
  for_each = toset(var.repo_names)
  name = each.value
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = false }
}

output "repo_urls" {
  value = { for k, r in aws_ecr_repository.repos : k => r.repository_url }
}
