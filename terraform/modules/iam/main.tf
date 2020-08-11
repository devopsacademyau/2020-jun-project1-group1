resource "aws_iam_user" "github" {
  name = "github-actions"
  path = "/ci/github/"
}

resource "aws_iam_access_key" "github" {
  user = aws_iam_user.github.name
}

resource "aws_iam_user_policy" "github" {
  name   = "github-actions-policy"
  user   = aws_iam_user.github.name
  policy = file("./policies/github.json")
}