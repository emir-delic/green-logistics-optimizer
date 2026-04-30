# 1. Declare the variable to receive the Lambda ARN from the root main.tf
variable "lambda_uri" {
  description = "The Invoke ARN of the Lambda function from the lambda module"
  type        = string
}

resource "aws_api_gateway_rest_api" "logistics_api" {
  name        = "green-logistics-optimizer-gateway-edelic"
  description = "Sovereign Gateway for Green Logistics"
  endpoint_configuration { 
    types = ["REGIONAL"] 
  }
  tags = {
    aws_cert_developer = "emir.delic"
  }
}

# 2. Add the missing resource (the URL path /calculate-route)
resource "aws_api_gateway_resource" "calculate_route" {
  rest_api_id = aws_api_gateway_rest_api.logistics_api.id
  parent_id   = aws_api_gateway_rest_api.logistics_api.root_resource_id
  path_part   = "calculate-route"
}

# 3. Add the missing method (POST)
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.logistics_api.id
  resource_id   = aws_api_gateway_resource.calculate_route.id
  http_method   = "POST"
  authorization = "NONE"
}

# 4. Corrected integration using the variable 'lambda_uri'
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.logistics_api.id
  resource_id             = aws_api_gateway_resource.calculate_route.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY" # Critical for index.js event parsing
  uri                     = var.lambda_uri 
}

# The Snapshot
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.logistics_api.id

  # Ensures redeployment when any part of the API changes
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.calculate_route.id,
      aws_api_gateway_method.post_method.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# The actual URL Environment
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.logistics_api.id
  stage_name    = "prod"
}

# OUTPUTS: These allow the root main.tf to pass IDs to your Lambda module
output "api_id" {
  value = aws_api_gateway_rest_api.logistics_api.id
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.logistics_api.root_resource_id
}

output "invoke_url" {
  value = "${aws_api_gateway_stage.prod.invoke_url}/calculate-route"
}