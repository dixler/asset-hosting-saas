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
  value = "${aws_iam_policy.read-assets-table.arn}"
}
output "read-tokens-table-policy" {
  value = "${aws_iam_policy.read-tokens-table.arn}"
}
output "read-users-table-policy" {
  value = "${aws_iam_policy.read-users-table.arn}"
}
output "read-timeseries-table-policy" {
  value = "${aws_iam_policy.read-timeseries-table.arn}"
}
output "read-assets-bucket-policy" {
  value = "${aws_iam_policy.read-assets-bucket.arn}"
}


resource "aws_iam_policy" "read-assets-table" {
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
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:GetItem",
                "dynamodb:GetShardIterator",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:ListStreams",
                "dynamodb:GetRecords"
            ],
            "Resource": "${var.assets-table-arn}"
        }
    ]
}
EOF
}
resource "aws_iam_policy" "read-tokens-table" {
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
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:GetItem",
                "dynamodb:GetShardIterator",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:ListStreams",
                "dynamodb:GetRecords"
            ],
            "Resource": "${var.tokens-table-arn}"
        }
    ]
}
EOF
}
resource "aws_iam_policy" "read-users-table" {
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
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:GetItem",
                "dynamodb:GetShardIterator",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:ListStreams",
                "dynamodb:GetRecords"
            ],
            "Resource": "${var.users-table-arn}"
        }
    ]
}
EOF
}
resource "aws_iam_policy" "read-timeseries-table" {
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
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:GetItem",
                "dynamodb:GetShardIterator",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:ListStreams",
                "dynamodb:GetRecords"
            ],
            "Resource": "${var.timeseries-table-arn}"
        }
    ]
}
EOF
}
resource "aws_iam_policy" "read-assets-bucket" {
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
               "s3:GetObject"
            ],
            "Resource": "${var.assets-bucket-arn}/*"
        }
    ]
}
EOF
}

