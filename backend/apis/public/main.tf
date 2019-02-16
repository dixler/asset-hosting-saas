provider "aws" {
  region = "us-east-1"
}
variable "region" {
  type = "string"
  default = "us-east-1"
}

variable "account_id"{
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

resource "aws_iam_role" "login-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "login-role-attachhment-debug" {
    role       = "${aws_iam_role.login-role.name}"
    policy_arn = "${aws_iam_policy.debugging-policy.arn}"
}
resource "aws_iam_role_policy_attachment" "login-role-attachment-0" {
    role       = "${aws_iam_role.login-role.name}"
    policy_arn = "${var.read-users-table-policy}"
}
resource "aws_iam_role_policy_attachment" "login-role-attachment-1" {
    role       = "${aws_iam_role.login-role.name}"
    policy_arn = "${var.write-users-table-policy}"
}
resource "aws_iam_role_policy_attachment" "login-role-attachment-2" {
    role       = "${aws_iam_role.login-role.name}"
    policy_arn = "${var.read-tokens-table-policy}"
}
resource "aws_iam_role_policy_attachment" "login-role-attachment-3" {
    role       = "${aws_iam_role.login-role.name}"
    policy_arn = "${var.write-tokens-table-policy}"
}

resource "aws_lambda_function" "login" {
  function_name = "${var.prefix}-login"
  filename         = "${path.module}/assets/login.zip"
  handler          = "login.lambda_handler"
  source_code_hash = "${base64sha256(file("${path.module}/assets/login.zip"))}"
  timeout          = 30
  runtime          = "python3.6"
  role             = "${aws_iam_role.login-role.arn}"

  environment {
    variables = {
      OAUTH_ID = "${var.oauth-id}"
      OAUTH_SECRET = "${var.oauth-secret}"

      TOKENS_TABLE_NAME = "${var.tokens-table-name}"
      USERS_TABLE_NAME = "${var.users-table-name}"
      S3_HOSTING_BUCKET = "${var.s3-hosting-bucket}"
      PREFIX = "${var.prefix}"
    }
  }
}

resource "aws_iam_role" "logout-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "logout-role-attachment-0" {
    role       = "${aws_iam_role.logout-role.name}"
    policy_arn = "${var.read-tokens-table-policy}"
}
resource "aws_iam_role_policy_attachment" "logout-role-attachment-1" {
    role       = "${aws_iam_role.logout-role.name}"
    policy_arn = "${var.write-tokens-table-policy}"
}

resource "aws_lambda_function" "logout" {
  function_name = "${var.prefix}-logout"
  filename         = "${path.module}/assets/logout.zip"
  handler          = "logout.lambda_handler"
  source_code_hash = "${base64sha256(file("${path.module}/assets/logout.zip"))}"
  runtime          = "python3.6"
  role             = "${aws_iam_role.logout-role.arn}"

  environment {
    variables = {
      TOKENS_TABLE_NAME = "${var.tokens-table-name}"
    }
  }
}

resource "aws_iam_policy" "debugging-policy" {
  path        = "/"
  description = ""

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "getUser-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "getUser-role-attachhment-debug" {
    role       = "${aws_iam_role.getUser-role.name}"
    policy_arn = "${aws_iam_policy.debugging-policy.arn}"
}
resource "aws_iam_role_policy_attachment" "getUser-role-attachment-0" {
    role       = "${aws_iam_role.getUser-role.name}"
    policy_arn = "${var.read-tokens-table-policy}"
}
resource "aws_iam_role_policy_attachment" "getUser-role-attachment-1" {
    role       = "${aws_iam_role.getUser-role.name}"
    policy_arn = "${var.read-users-table-policy}"
}

resource "aws_lambda_function" "getUser" {
  function_name = "${var.prefix}-getUser"
  filename         = "${path.module}/assets/getUser.zip"
  handler          = "getUser.lambda_handler"
  source_code_hash = "${base64sha256(file("${path.module}/assets/getUser.zip"))}"
  runtime          = "python3.6"
  role             = "${aws_iam_role.getUser-role.arn}"

  environment {
    variables = {
      TOKENS_TABLE_NAME = "${var.tokens-table-name}"
      USERS_TABLE_NAME = "${var.users-table-name}"
    }
  }
}
resource "aws_iam_role" "getAssets-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "getAssets-role-attachment-debug" {
    role       = "${aws_iam_role.getAssets-role.name}"
    policy_arn = "${aws_iam_policy.debugging-policy.arn}"
}
resource "aws_iam_role_policy_attachment" "getAssets-role-attachment-0" {
    role       = "${aws_iam_role.getAssets-role.name}"
    policy_arn = "${var.read-tokens-table-policy}"
}
resource "aws_iam_role_policy_attachment" "getAssets-role-attachment-1" {
    role       = "${aws_iam_role.getAssets-role.name}"
    policy_arn = "${var.read-assets-table-policy}"
}

resource "aws_lambda_function" "getAssets" {
  function_name = "${var.prefix}-getAssets"
  filename         = "${path.module}/assets/getAssets.zip"
  handler          = "getAssets.lambda_handler"
  source_code_hash = "${base64sha256(file("${path.module}/assets/getAssets.zip"))}"
  runtime          = "python3.6"
  role             = "${aws_iam_role.getAssets-role.arn}"

  environment {
    variables = {
      ASSETS_TABLE_NAME = "${var.assets-table-name}"
      TOKENS_TABLE_NAME = "${var.tokens-table-name}"
    }
  }
}
resource "aws_iam_role" "retrieveAsset-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "retrieveAsset-role-attachment-debug" {
    role       = "${aws_iam_role.retrieveAsset-role.name}"
    policy_arn = "${aws_iam_policy.debugging-policy.arn}"
}
resource "aws_iam_role_policy_attachment" "retrieveAsset-role-attachment-0" {
    role       = "${aws_iam_role.retrieveAsset-role.name}"
    policy_arn = "${var.read-assets-table-policy}"
}
resource "aws_iam_role_policy_attachment" "retrieveAsset-role-attachment-1" {
    role       = "${aws_iam_role.retrieveAsset-role.name}"
    policy_arn = "${var.read-timeseries-table-policy}"
}
resource "aws_iam_role_policy_attachment" "retrieveAsset-role-attachment-2" {
    role       = "${aws_iam_role.retrieveAsset-role.name}"
    policy_arn = "${var.write-timeseries-table-policy}"
}

resource "aws_lambda_function" "retrieveAsset" {
  function_name = "${var.prefix}-retrieveAsset"
  filename         = "${path.module}/assets/retrieveAsset.zip"
  handler          = "retrieveAsset.lambda_handler"
  source_code_hash = "${base64sha256(file("${path.module}/assets/retrieveAsset.zip"))}"
  runtime          = "python3.6"
  role             = "${aws_iam_role.retrieveAsset-role.arn}"

  environment {
    variables = {
      ASSETS_TABLE_NAME = "${var.assets-table-name}"
      TIMESERIES_TABLE_NAME = "${var.timeseries-table-name}"
    }
  }
}
resource "aws_iam_role" "deleteAsset-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "deleteAsset-role-attachment-debug" {
    role       = "${aws_iam_role.deleteAsset-role.name}"
    policy_arn = "${aws_iam_policy.debugging-policy.arn}"
}
resource "aws_iam_role_policy_attachment" "deleteAsset-role-attachment-0" {
    role       = "${aws_iam_role.deleteAsset-role.name}"
    policy_arn = "${var.read-tokens-table-policy}"
}
resource "aws_iam_role_policy_attachment" "deleteAsset-role-attachment-1" {
    role       = "${aws_iam_role.deleteAsset-role.name}"
    policy_arn = "${var.read-assets-table-policy}"
}
resource "aws_iam_role_policy_attachment" "deleteAsset-role-attachment-2" {
    role       = "${aws_iam_role.deleteAsset-role.name}"
    policy_arn = "${var.write-assets-table-policy}"
}
resource "aws_iam_role_policy_attachment" "deleteAsset-role-attachment-3" {
    role       = "${aws_iam_role.deleteAsset-role.name}"
    policy_arn = "${var.read-users-table-policy}"
}
resource "aws_iam_role_policy_attachment" "deleteAsset-role-attachment-4" {
    role       = "${aws_iam_role.deleteAsset-role.name}"
    policy_arn = "${var.write-users-table-policy}"
}
resource "aws_iam_role_policy_attachment" "deleteAsset-role-attachment-5" {
    role       = "${aws_iam_role.deleteAsset-role.name}"
    policy_arn = "${var.write-assets-bucket-policy}"
}
resource "aws_iam_role_policy_attachment" "deleteAsset-role-attachment-6" {
    role       = "${aws_iam_role.deleteAsset-role.name}"
    policy_arn = "${var.read-assets-bucket-policy}"
}
resource "aws_iam_role_policy_attachment" "deleteAsset-role-attachment-7" {
    role       = "${aws_iam_role.deleteAsset-role.name}"
    policy_arn = "${var.read-tokens-table-policy}"
}

resource "aws_lambda_function" "deleteAsset" {
  function_name = "${var.prefix}-deleteAsset"
  filename         = "${path.module}/assets/deleteAsset.zip"
  handler          = "deleteAsset.lambda_handler"
  source_code_hash = "${base64sha256(file("${path.module}/assets/deleteAsset.zip"))}"
  runtime          = "python3.6"
  role             = "${aws_iam_role.deleteAsset-role.arn}"

  environment {
    variables = {
      ASSETS_TABLE_NAME = "${var.assets-table-name}"
      ASSETS_BUCKET_NAME = "${var.assets-bucket-name}"
      TOKENS_TABLE_NAME = "${var.tokens-table-name}"
      USERS_TABLE_NAME = "${var.users-table-name}"
    }
  }
}
resource "aws_iam_role" "createAsset-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "createAsset-role-attachment-debug" {
    role       = "${aws_iam_role.createAsset-role.name}"
    policy_arn = "${aws_iam_policy.debugging-policy.arn}"
}
resource "aws_iam_role_policy_attachment" "createAsset-role-attachment-0" {
    role       = "${aws_iam_role.createAsset-role.name}"
    policy_arn = "${var.read-tokens-table-policy}"
}
resource "aws_iam_role_policy_attachment" "createAsset-role-attachment-1" {
    role       = "${aws_iam_role.createAsset-role.name}"
    policy_arn = "${var.read-assets-table-policy}"
}
resource "aws_iam_role_policy_attachment" "createAsset-role-attachment-2" {
    role       = "${aws_iam_role.createAsset-role.name}"
    policy_arn = "${var.write-assets-table-policy}"
}
resource "aws_iam_role_policy_attachment" "createAsset-role-attachment-3" {
    role       = "${aws_iam_role.createAsset-role.name}"
    policy_arn = "${var.read-users-table-policy}"
}
resource "aws_iam_role_policy_attachment" "createAsset-role-attachment-4" {
    role       = "${aws_iam_role.createAsset-role.name}"
    policy_arn = "${var.write-users-table-policy}"
}
resource "aws_iam_role_policy_attachment" "createAsset-role-attachment-5" {
    role       = "${aws_iam_role.createAsset-role.name}"
    policy_arn = "${var.write-assets-bucket-policy}"
}
resource "aws_iam_role_policy_attachment" "createAsset-role-attachment-6" {
    role       = "${aws_iam_role.createAsset-role.name}"
    policy_arn = "${var.read-assets-bucket-policy}"
}
resource "aws_iam_role_policy_attachment" "createAsset-role-attachment-7" {
    role       = "${aws_iam_role.createAsset-role.name}"
    policy_arn = "${var.read-tokens-table-policy}"
}

resource "aws_lambda_function" "createAsset" {
  function_name = "${var.prefix}-createAsset"
  filename         = "${path.module}/assets/createAsset.zip"
  handler          = "createAsset.lambda_handler"
  source_code_hash = "${base64sha256(file("${path.module}/assets/createAsset.zip"))}"
  runtime          = "python3.6"
  timeout          = 30
  role             = "${aws_iam_role.createAsset-role.arn}"

  environment {
    variables = {
      ASSETS_TABLE_NAME = "${var.assets-table-name}"
      ASSETS_BUCKET_NAME = "${var.assets-bucket-name}"
      TOKENS_TABLE_NAME = "${var.tokens-table-name}"
      USERS_TABLE_NAME = "${var.users-table-name}"
    }
  }
}


# API-Gateway
resource "aws_api_gateway_rest_api" "api-gateway" {
  name        = "${var.prefix}-api-gateway"
  description = "api gateway for ${var.prefix}"
}
resource "aws_api_gateway_deployment" "api-deployment" {
  depends_on = [
    "aws_api_gateway_integration.login-integration",
    "aws_api_gateway_integration.logout-integration",
    "aws_api_gateway_integration.createAsset-integration",
    "aws_api_gateway_integration.retrieveAsset-integration",
    "aws_api_gateway_integration.deleteAsset-integration",
    "aws_api_gateway_integration.getUser-integration",
    "aws_api_gateway_integration.getAssets-integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  stage_name  = "dev"
  variables {
    deployed_at = "testing-0"
  }
}
output "aws-api-endpoint" {
  value = "${aws_api_gateway_deployment.api-deployment.invoke_url}"
}

module "login-route-cors" {
  source = "./terraform-api-gateway-cors-module"
  resource_id = "${aws_api_gateway_resource.login-route.id}"
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
}
resource "aws_api_gateway_resource" "login-route" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  path_part   = "login"
}
resource "aws_api_gateway_method" "login-method" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.login-route.id}"
  http_method = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "login-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  http_method = "${aws_api_gateway_method.login-method.http_method}"
  resource_id = "${aws_api_gateway_resource.login-route.id}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.login.function_name}/invocations"
  integration_http_method = "POST"
}
resource "aws_lambda_permission" "login-apig-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.login.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api-gateway.id}/*/${aws_api_gateway_method.login-method.http_method}${aws_api_gateway_resource.login-route.path}"
}
module "logout-route-cors" {
  source = "./terraform-api-gateway-cors-module"
  resource_id = "${aws_api_gateway_resource.logout-route.id}"
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
}
resource "aws_api_gateway_resource" "logout-route" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  path_part   = "logout"
}
resource "aws_api_gateway_method" "logout-method" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.logout-route.id}"
  http_method = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "logout-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  http_method = "${aws_api_gateway_method.logout-method.http_method}"
  resource_id = "${aws_api_gateway_resource.logout-route.id}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.logout.function_name}/invocations"
  integration_http_method = "POST"
}
resource "aws_lambda_permission" "logout-apig-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.logout.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api-gateway.id}/*/${aws_api_gateway_method.logout-method.http_method}${aws_api_gateway_resource.logout-route.path}"
}
module "createAsset-route-cors" {
  source = "./terraform-api-gateway-cors-module"
  resource_id = "${aws_api_gateway_resource.createAsset-route.id}"
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
}
resource "aws_api_gateway_resource" "createAsset-route" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  path_part   = "createAsset"
}
resource "aws_api_gateway_method" "createAsset-method" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.createAsset-route.id}"
  http_method = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "createAsset-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  http_method = "${aws_api_gateway_method.createAsset-method.http_method}"
  resource_id = "${aws_api_gateway_resource.createAsset-route.id}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.createAsset.function_name}/invocations"
  integration_http_method = "POST"
}
resource "aws_lambda_permission" "createAsset-apig-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.createAsset.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api-gateway.id}/*/${aws_api_gateway_method.createAsset-method.http_method}${aws_api_gateway_resource.createAsset-route.path}"
}
module "deleteAsset-route-cors" {
  source = "./terraform-api-gateway-cors-module"
  resource_id = "${aws_api_gateway_resource.deleteAsset-route.id}"
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
}
resource "aws_api_gateway_resource" "deleteAsset-route" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  path_part   = "deleteAsset"
}
resource "aws_api_gateway_method" "deleteAsset-method" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.deleteAsset-route.id}"
  http_method = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "deleteAsset-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  http_method = "${aws_api_gateway_method.deleteAsset-method.http_method}"
  resource_id = "${aws_api_gateway_resource.deleteAsset-route.id}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.deleteAsset.function_name}/invocations"
  integration_http_method = "POST"
}
resource "aws_lambda_permission" "deleteAsset-apig-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.deleteAsset.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api-gateway.id}/*/${aws_api_gateway_method.deleteAsset-method.http_method}${aws_api_gateway_resource.deleteAsset-route.path}"
}
module "getUser-route-cors" {
  source = "./terraform-api-gateway-cors-module"
  resource_id = "${aws_api_gateway_resource.getUser-route.id}"
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
}
resource "aws_api_gateway_resource" "getUser-route" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  path_part   = "getUser"
}
resource "aws_api_gateway_method" "getUser-method" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.getUser-route.id}"
  http_method = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "getUser-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  http_method = "${aws_api_gateway_method.getUser-method.http_method}"
  resource_id = "${aws_api_gateway_resource.getUser-route.id}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.getUser.function_name}/invocations"
  integration_http_method = "POST"
}
resource "aws_lambda_permission" "getUser-apig-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.getUser.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api-gateway.id}/*/${aws_api_gateway_method.getUser-method.http_method}${aws_api_gateway_resource.getUser-route.path}"
}
module "getAssets-route-cors" {
  source = "./terraform-api-gateway-cors-module"
  resource_id = "${aws_api_gateway_resource.getAssets-route.id}"
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
}
resource "aws_api_gateway_resource" "getAssets-route" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  path_part   = "getAssets"
}
resource "aws_api_gateway_method" "getAssets-method" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.getAssets-route.id}"
  http_method = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "getAssets-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  http_method = "${aws_api_gateway_method.getAssets-method.http_method}"
  resource_id = "${aws_api_gateway_resource.getAssets-route.id}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.getAssets.function_name}/invocations"
  integration_http_method = "POST"
}
resource "aws_lambda_permission" "getAssets-apig-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.getAssets.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api-gateway.id}/*/${aws_api_gateway_method.getAssets-method.http_method}${aws_api_gateway_resource.getAssets-route.path}"
}
module "retrieveAsset-route-cors" {
  source = "./terraform-api-gateway-cors-module"
  resource_id = "${aws_api_gateway_resource.retrieveAsset-route.id}"
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
}
resource "aws_api_gateway_resource" "retrieveAsset-route" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  path_part   = "retrieveAsset"
}
resource "aws_api_gateway_method" "retrieveAsset-method" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.retrieveAsset-route.id}"
  http_method = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "retrieveAsset-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  http_method = "${aws_api_gateway_method.retrieveAsset-method.http_method}"
  resource_id = "${aws_api_gateway_resource.retrieveAsset-route.id}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.retrieveAsset.function_name}/invocations"
  integration_http_method = "POST"
}
resource "aws_lambda_permission" "retrieveAsset-apig-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.retrieveAsset.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api-gateway.id}/*/${aws_api_gateway_method.retrieveAsset-method.http_method}${aws_api_gateway_resource.retrieveAsset-route.path}"
}
