resource "aws_ecr_repository" "repo" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  tags = merge(var.common_tags, {
    Name = "devops-${var.repository_name}"
  })

  image_scanning_configuration {
    scan_on_push = true
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}