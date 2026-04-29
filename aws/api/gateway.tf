resource "aws_api_gateway_rest_api" "logistics_api" {
  name        = "green-logistics-optimizer-gateway-edelic"
  description = "Sovereign Gateway for Green Logistics"
  endpoint_configuration { types = ["REGIONAL"] }
}

# The Snapshot
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.logistics_api.id

  # Forces a new deployment if the API structure changes
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

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.logistics_api.id
  resource_id             = aws_api_gateway_resource.calculate_route.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY" # CRITICAL for your index.js parsing
  uri                     = aws_lambda_function.optimizer.invoke_arn
}

output "api_id" {
  value = aws_api_gateway_rest_api.logistics_api.id
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.logistics_api.root_resource_id
}