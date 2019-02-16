provider "aws" {
  region = "us-east-1"
}
variable "prefix" {
  type = "string"
}

output "assets-table-name" {
  value = "${aws_dynamodb_table.assets-table.name}"
}
output "tokens-table-name" {
  value = "${aws_dynamodb_table.tokens-table.name}"
}
output "users-table-name" {
  value = "${aws_dynamodb_table.users-table.name}"
}
output "timeseries-table-name" {
  value = "${aws_dynamodb_table.timeseries-table.name}"
}
output "assets-bucket-name" {
  value = "${aws_s3_bucket.assets-bucket.bucket}"
}

output "read-assets-table-policy" {
  value = "${module.iam-policies.read-assets-table-policy}"
}
output "read-tokens-table-policy" {
  value = "${module.iam-policies.read-tokens-table-policy}"
}
output "read-users-table-policy" {
  value = "${module.iam-policies.read-users-table-policy}"
}
output "read-timeseries-table-policy" {
  value = "${module.iam-policies.read-timeseries-table-policy}"
}
output "read-assets-bucket-policy" {
  value = "${module.iam-policies.read-assets-bucket-policy}"
}


output "write-assets-table-policy" {
  value = "${module.iam-policies.write-assets-table-policy}"
}
output "write-tokens-table-policy" {
  value = "${module.iam-policies.write-tokens-table-policy}"
}
output "write-users-table-policy" {
  value = "${module.iam-policies.write-users-table-policy}"
}
output "write-timeseries-table-policy" {
  value = "${module.iam-policies.write-timeseries-table-policy}"
}
output "write-assets-bucket-policy" {
  value = "${module.iam-policies.write-assets-bucket-policy}"
}


module "iam-policies" {
  source = "./iam"
  prefix = "${var.prefix}"
  assets-table-arn = "${aws_dynamodb_table.assets-table.arn}"
  tokens-table-arn = "${aws_dynamodb_table.tokens-table.arn}"
  users-table-arn = "${aws_dynamodb_table.users-table.arn}"
  timeseries-table-arn = "${aws_dynamodb_table.timeseries-table.arn}"
  assets-bucket-arn = "${aws_s3_bucket.assets-bucket.arn}"
}

resource "aws_dynamodb_table" "tokens-table" {
  name           = "${var.prefix}-tokens-table"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "token"

  attribute {
    name = "token"
    type = "S"
  }

  tags {
    CostCenter        = "UIC"
    Environment = "production"
  }
}

resource "aws_dynamodb_table" "users-table" {
  name           = "${var.prefix}-users-table"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  tags {
    CostCenter        = "UIC"
    Environment = "production"
  }

}

resource "aws_dynamodb_table" "timeseries-table" {
  name           = "${var.prefix}-timeseries-table"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "seq"
  range_key      = "assetId"

  attribute {
    name = "seq"
    type = "S"
  }

  attribute {
    name = "assetId"
    type = "S"
  }

  tags {
    CostCenter        = "UIC"
    Environment = "production"
  }
}

resource "aws_dynamodb_table" "assets-table" {
  name           = "${var.prefix}-assets-table"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "assetId"

  attribute {
    name = "assetId"
    type = "S"
  }

  tags {
    CostCenter        = "UIC"
    Environment = "production"
  }
}

resource "aws_s3_bucket" "assets-bucket" {
  tags {
    CostCenter        = "UIC"
    Environment = "production"
  }
}

