variable "aws_account_id" {}
variable "api_id" {}
variable "root_resource_id" {}

# 1. IAM Role for THIS specific function
resource "aws_iam_role" "lambda_role" {
  name = "green-logistics-optimizer-lambda-role-edelic"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

# 2. Attach basic execution (Logging)
resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 3. Zip and Function Definition
data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}"
  output_path = "${path.module}/../../files/optimizer.zip"
}

resource "aws_lambda_function" "optimizer" {
  function_name = "green-logistics-optimizer-lambda-edelic"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.optimizer.function_name
  principal     = "apigateway.amazonaws.com"

  # More secure: Restrict to only your specific API
  source_arn = "arn:aws:execute-api:eu-central-1:${var.aws_account_id}:${aws_api_gateway_rest_api.logistics_api.id}/*/*"
}