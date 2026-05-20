# --- Module Variables ---
variable "aws_account_id" {}
variable "api_id" {}
variable "root_resource_id" {}
variable "poly_api_key" {
  type      = string
  sensitive = true
}

variable "lambda_zip_path" {
  type        = string
  description = "Dynamic zip name passed from root"
}

# --- IAM Role ---
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

# --- Lambda Function ---
resource "aws_lambda_function" "optimizer" {
  function_name    = "green-logistics-optimizer-lambda-edelic"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler" 
  runtime          = "nodejs20.x"
  
  filename         = "${path.cwd}/${var.lambda_zip_path}"
  source_code_hash = filebase64sha256("${path.cwd}/${var.lambda_zip_path}")

  # --- CRITICAL UPDATES ---
  
  # Increase memory to 512MB. 
  # This doesn't just give you more RAM; it gives you a faster CPU.
  memory_size = 512 

  # Increase timeout to 30 seconds.
  # Cold starts + PolyAPI logic might take 5-10 seconds the first time.
  timeout = 90 

  environment {
    variables = {
      POLY_API_KEY = var.poly_api_key
    }
  }

  tags = {
    aws_cert_developer = "emir.delic"
  }
}

# --- Permissions ---
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