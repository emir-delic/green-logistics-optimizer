# main.tf in the project root

provider "aws" {
  region = "eu-central-1"
}

variable "aws_account_id" {
  type      = string
  sensitive = true
}

# 1. Include the API Gateway Folder
module "api" {
  source = "./aws/api"
}

# 2. Include the Lambda Folder
module "green_logistics_lambda" {
  source         = "./aws/lambda/green-logistics-optimizer-edelic"
  # Pass variables needed by the lambda.tf file
  aws_account_id = var.aws_account_id
  api_id         = module.api.api_id
  root_resource_id = module.api.root_resource_id
}