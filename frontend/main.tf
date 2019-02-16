provider "aws" {
  region = "us-east-1"
}

variable "region" {
  type = "string"
  default = "us-east-1"
}

variable "prefix" {
  type = "string"
  default = "dev"
}

variable "aws-api-endpoint" {
  type = "string"
  default = ""
}

variable "google-oauth-id" {
  type = "string"
  default = ""
}

variable "google-oauth-secret" {
  type = "string"
  default = ""
}

output "static-hosting-bucket" {
  value = "http://localhost:8080"
}

module "storage" {
  source = "./storage"
  region = "${var.region}"
  prefix = "${var.prefix}"
}
