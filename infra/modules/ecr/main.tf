# infra/modules/ecr/main.tf
resource "aws_ecr_repository" "microservice" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.microservice.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only 3 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 3
      }
      action = { type = "expire" }
    }]
  })
}