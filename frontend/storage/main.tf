provider "aws" {
  region = "us-east-1"
}
variable "prefix" {
  type = "string"
}
variable "region" {
  type = "string"
}

resource "aws_s3_bucket" "assets-bucket" {
  tags {
    CostCenter        = "UIC"
    Environment = "production"
  }
}

