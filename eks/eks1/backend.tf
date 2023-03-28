terraform {
  backend "s3" {
    bucket         = "s3-terraform-tfstate-file"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-tfstate-file"
  }
}