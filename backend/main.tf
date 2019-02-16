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

variable "s3-hosting-bucket" {
  type = "string"
}

variable "google-oauth-id" {
  type = "string"
}

variable "google-oauth-secret" {
  type = "string"
}

module "storage" {
  source = "./storage"
  prefix = "${var.prefix}"
}

output "aws-api-endpoint" {
  value = "${module.apis.aws-api-endpoint}"
}

data "aws_caller_identity" "current" {}

module "apis" {
  source = "./apis"
  prefix = "${var.prefix}"
  region = "${var.region}"
  account_id = "${data.aws_caller_identity.current.account_id}"

  # oauth
  oauth-id = "${var.google-oauth-id}"
  oauth-secret = "${var.google-oauth-secret}"

  s3-hosting-bucket = "${var.s3-hosting-bucket}"

  # storage endpoints
  assets-table-name = "${module.storage.assets-table-name}"
  tokens-table-name = "${module.storage.tokens-table-name}"
  users-table-name = "${module.storage.users-table-name}"
  timeseries-table-name = "${module.storage.timeseries-table-name}"
  assets-bucket-name = "${module.storage.assets-bucket-name}"

  # oauth data

  # iam policies
  read-assets-table-policy = "${module.storage.read-assets-table-policy}"
  read-tokens-table-policy = "${module.storage.read-tokens-table-policy}"
  read-users-table-policy = "${module.storage.read-users-table-policy}"
  read-timeseries-table-policy = "${module.storage.read-timeseries-table-policy}"
  read-assets-bucket-policy = "${module.storage.read-assets-bucket-policy}"


  write-assets-table-policy = "${module.storage.write-assets-table-policy}"
  write-tokens-table-policy = "${module.storage.write-tokens-table-policy}"
  write-users-table-policy = "${module.storage.write-users-table-policy}"
  write-timeseries-table-policy = "${module.storage.write-timeseries-table-policy}"
  write-assets-bucket-policy = "${module.storage.write-assets-bucket-policy}"

}
