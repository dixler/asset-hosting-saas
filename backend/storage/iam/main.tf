provider "aws" {
  region = "us-east-1"
}

variable "prefix" {
  type = "string"
}

variable "assets-table-arn" {
  type = "string"
}
variable "tokens-table-arn" {
  type = "string"
}
variable "users-table-arn" {
  type = "string"
}
variable "timeseries-table-arn" {
  type = "string"
}
variable "assets-bucket-arn" {
  type = "string"
}


output "read-assets-table-policy" {
  value = "${module.read-policies.read-assets-table-policy}"
}
output "read-tokens-table-policy" {
  value = "${module.read-policies.read-tokens-table-policy}"
}
output "read-users-table-policy" {
  value = "${module.read-policies.read-users-table-policy}"
}
output "read-timeseries-table-policy" {
  value = "${module.read-policies.read-timeseries-table-policy}"
}
output "read-assets-bucket-policy" {
  value = "${module.read-policies.read-assets-bucket-policy}"
}


output "write-assets-table-policy" {
  value = "${module.write-policies.write-assets-table-policy}"
}
output "write-tokens-table-policy" {
  value = "${module.write-policies.write-tokens-table-policy}"
}
output "write-users-table-policy" {
  value = "${module.write-policies.write-users-table-policy}"
}
output "write-timeseries-table-policy" {
  value = "${module.write-policies.write-timeseries-table-policy}"
}
output "write-assets-bucket-policy" {
  value = "${module.write-policies.write-assets-bucket-policy}"
}


module "read-policies" {
  source = "./read"
  prefix = "${var.prefix}"
  assets-table-arn = "${var.assets-table-arn}"
  tokens-table-arn = "${var.tokens-table-arn}"
  users-table-arn = "${var.users-table-arn}"
  timeseries-table-arn = "${var.timeseries-table-arn}"
  assets-bucket-arn = "${var.assets-bucket-arn}"
}

module "write-policies" {
  source = "./write"
  prefix = "${var.prefix}"
  assets-table-arn = "${var.assets-table-arn}"
  tokens-table-arn = "${var.tokens-table-arn}"
  users-table-arn = "${var.users-table-arn}"
  timeseries-table-arn = "${var.timeseries-table-arn}"
  assets-bucket-arn = "${var.assets-bucket-arn}"
}
