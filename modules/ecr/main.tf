resource "aws_ecr_repository" "app" {
  name                 = "${var.resource_prefix}-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Good practice: Delete old images to save costs
  force_delete = true
}

output "repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}