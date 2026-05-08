variable "aws_account_id" {}
variable "api_id" {}
variable "root_resource_id" {}
variable "poly_api_key" {
  type      = string
  sensitive = true
}

resource "aws_iam_role" "lambda_role" {
  name = "green-logistics-optimizer-lambda-role-edelic"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ 
        Action = "sts:AssumeRole", 
        Effect = "Allow", 
        Principal = { Service = "lambda.amazonaws.com" } 
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}"
  excludes    = ["lambda.tf", "poly_sdk_layer.zip"] 
  output_path = "${path.module}/../../files/optimizer.zip"

  # MANUALLY INJECT the generated SDK into the function zip
  source {
    content  = file("${path.cwd}/node_modules/polyapi/index.js")
    filename = "node_modules/polyapi/index.js"
  }
  source {
    content  = file("${path.cwd}/node_modules/polyapi/package.json")
    filename = "node_modules/polyapi/package.json"
  }
}

resource "aws_lambda_function" "optimizer" {
  function_name    = "green-logistics-optimizer-lambda-edelic"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  # REMOVE the layers = [...] line here to keep it simple

  environment {
    variables = {
      NODE_ENV     = "production"
      POLY_API_KEY = var.poly_api_key
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.optimizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:eu-central-1:${var.aws_account_id}:${var.api_id}/*/*"
}

output "invoke_arn" {
  value = aws_lambda_function.optimizer.invoke_arn
}