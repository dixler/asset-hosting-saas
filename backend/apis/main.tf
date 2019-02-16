provider "aws" {
  region = "us-east-1"
}

variable "region" {
  type = "string"
}

variable "account_id" {
  type = "string"
}

variable "prefix" {
  type = "string"
}


variable "oauth-id" {
  type = "string"
}
variable "oauth-secret" {
  type = "string"
}

variable "s3-hosting-bucket" {
  type = "string"
}

output "aws-api-endpoint" {
  value = "${module.public-apis.aws-api-endpoint}"
}
variable "assets-table-name" {
  type = "string"
}
variable "tokens-table-name" {
  type = "string"
}
variable "users-table-name" {
  type = "string"
}
variable "timeseries-table-name" {
  type = "string"
}
variable "assets-bucket-name" {
  type = "string"
}


variable "read-assets-table-policy" {
  type = "string"
}
variable "read-tokens-table-policy" {
  type = "string"
}
variable "read-users-table-policy" {
  type = "string"
}
variable "read-timeseries-table-policy" {
  type = "string"
}
variable "read-assets-bucket-policy" {
  type = "string"
}


variable "write-assets-table-policy" {
  type = "string"
}
variable "write-tokens-table-policy" {
  type = "string"
}
variable "write-users-table-policy" {
  type = "string"
}
variable "write-timeseries-table-policy" {
  type = "string"
}
variable "write-assets-bucket-policy" {
  type = "string"
}

module "public-apis" {
  source = "./public"
  prefix = "${var.prefix}"
  account_id = "${var.account_id}"

  # endpoints
  oauth-id = "${var.oauth-id}"
  oauth-secret = "${var.oauth-secret}"

  s3-hosting-bucket = "${var.s3-hosting-bucket}"

  assets-table-name = "${var.assets-table-name}"
  tokens-table-name = "${var.tokens-table-name}"
  users-table-name = "${var.users-table-name}"
  timeseries-table-name = "${var.timeseries-table-name}"
  assets-bucket-name = "${var.assets-bucket-name}"

  # iam policies
  read-assets-table-policy = "${var.read-assets-table-policy}"
  read-tokens-table-policy = "${var.read-tokens-table-policy}"
  read-users-table-policy = "${var.read-users-table-policy}"
  read-timeseries-table-policy = "${var.read-timeseries-table-policy}"
  read-assets-bucket-policy = "${var.read-assets-bucket-policy}"

  write-assets-table-policy = "${var.write-assets-table-policy}"
  write-tokens-table-policy = "${var.write-tokens-table-policy}"
  write-users-table-policy = "${var.write-users-table-policy}"
  write-timeseries-table-policy = "${var.write-timeseries-table-policy}"
  write-assets-bucket-policy = "${var.write-assets-bucket-policy}"
}
