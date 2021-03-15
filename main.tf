data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

provider "aws" {
  region = "eu-west-1"
}

output "region" {
  value = data.aws_region.current.name
}
terraform {
  backend "s3" {
    bucket = "choirless-terraform-state"
    key = "choirless"
    region = "eu-west-1"
  }
}
