output "ecr_repository" {
  description = "attributes of the ecr repository created."
  value = {
    id             = aws_ecr_repository.repo.id
    arn            = aws_ecr_repository.repo.arn
    name           = aws_ecr_repository.repo.name
    repository_url = aws_ecr_repository.repo.repository_url
  }
}