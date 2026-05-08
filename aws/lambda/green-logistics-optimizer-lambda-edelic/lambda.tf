# Variables received from the root main.tf
variable "aws_account_id" {}
variable "api_id" {}
variable "root_resource_id" {}
variable "poly_api_key" {
  type      = string
  sensitive = true
}

# 1. IAM Role for THIS specific function
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

# 2. Attach basic execution (Logging) for audit trails
resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 3. Zip and Function Definition
# 3a. Create the PolyAPI SDK Layer
data "archive_file" "poly_sdk_zip" {
  type        = "zip"
  output_path = "${path.module}/poly_sdk_layer.zip"

  # AWS Layers require node_modules to be inside a /nodejs/ directory
  source {
    content  = " " 
    filename = "nodejs/keep" 
  }

  # This grabs your root polyapi installation
  source_dir = "${path.cwd}/node_modules/polyapi"
}

resource "aws_lambda_layer_version" "poly_sdk" {
  filename            = data.archive_file.poly_sdk_zip.output_path
  layer_name          = "poly_sdk_layer"
  compatible_runtimes = ["nodejs20.x"]
}

# 3b. Update Function Definition
resource "aws_lambda_function" "optimizer" {
  function_name = "green-logistics-optimizer-lambda-edelic"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  # ATTACH THE LAYER
  layers = [aws_lambda_layer_version.poly_sdk.arn]

  environment {
    variables = {
      NODE_ENV     = "production"
      POLY_API_KEY = var.poly_api_key # The Handshake Secret
    }
  }

  tags = {
    aws_cert_developer = "emir.delic"
  }
}

# 4. Grant API Gateway permission to invoke this Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.optimizer.function_name
  principal     = "apigateway.amazonaws.com"

  # FIX: Reference the variable var.api_id instead of the resource
  source_arn = "arn:aws:execute-api:eu-central-1:${var.aws_account_id}:${var.api_id}/*/*"
}

# 5. OUTPUT: Export the ARN so the root main.tf can pass it to the API module
output "invoke_arn" {
  value = aws_lambda_function.optimizer.invoke_arn
}