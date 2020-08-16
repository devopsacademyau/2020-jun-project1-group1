terraform {
  backend "s3" {
    bucket = "da-devops-terraform"
    key    = "terraform.tfstate"
    region = "ap-southeast-2"
    dynamodb_table = "da-devops-terraform-lock"
  }
}