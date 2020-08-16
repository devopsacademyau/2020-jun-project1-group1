output "github" {
  value = {
    user = aws_iam_access_key.github.user
    id   = aws_iam_access_key.github.id
  }
}