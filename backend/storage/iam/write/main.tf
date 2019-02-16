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

output "write-assets-table-policy" {
  value = "${aws_iam_policy.write-assets-table.arn}"
}
output "write-tokens-table-policy" {
  value = "${aws_iam_policy.write-tokens-table.arn}"
}
output "write-users-table-policy" {
  value = "${aws_iam_policy.write-users-table.arn}"
}
output "write-timeseries-table-policy" {
  value = "${aws_iam_policy.write-timeseries-table.arn}"
}
output "write-assets-bucket-policy" {
  value = "${aws_iam_policy.write-assets-bucket.arn}"
}

resource "aws_iam_policy" "write-assets-table" {
  path        = "/"
  description = ""

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "${var.assets-table-arn}"
        }
    ]
}
EOF
}
resource "aws_iam_policy" "write-tokens-table" {
  path        = "/"
  description = ""

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "${var.tokens-table-arn}"
        }
    ]
}
EOF
}
resource "aws_iam_policy" "write-users-table" {
  path        = "/"
  description = ""

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "${var.users-table-arn}"
        }
    ]
}
EOF
}
resource "aws_iam_policy" "write-timeseries-table" {
  path        = "/"
  description = ""

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "${var.timeseries-table-arn}"
        }
    ]
}
EOF
}
resource "aws_iam_policy" "write-assets-bucket" {
  path        = "/"
  description = ""

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Terraform",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion",
                "s3:PutObjectAcl"
            ],
            "Resource": "${var.assets-bucket-arn}/*"
        }
    ]
}
EOF
}

