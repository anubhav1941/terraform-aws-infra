terraform {
  backend "s3" {
    bucket = "anubhav-tf-state-2024"
    key    = "aws-infra/terraform.tfstate"
    region = "us-east-1"
  }
}
