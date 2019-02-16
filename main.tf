provider "aws" {
  region = "us-east-1"
}

variable "region" {
  type = "string"
  default = "us-east-1"
}

variable "prefix" {
  type = "string"
}

variable "google-oauth-id" {
  type = "string"
}

variable "google-oauth-secret" {
  type = "string"
}

output "aws-api-endpoint" {                                                                                                                                                               
  value = "${module.backend.aws-api-endpoint}"
}


module "backend" {
  source = "./backend"
  region = "${var.region}"
  prefix = "${var.prefix}"
  s3-hosting-bucket = "${module.frontend.static-hosting-bucket}"
  google-oauth-id = "${var.google-oauth-id}"
  google-oauth-secret = "${var.google-oauth-secret}"
}
module "frontend" {
  source = "./frontend"
  region = "${var.region}"
  prefix = "${var.prefix}"
  aws-api-endpoint = "${module.backend.aws-api-endpoint}"
  google-oauth-id = "${var.google-oauth-id}"
  google-oauth-secret = "${var.google-oauth-secret}"
}
