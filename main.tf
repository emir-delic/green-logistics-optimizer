# main.tf in the project root

terraform {
  # Combined Provider and Backend configuration
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "green-logistics-optimizer-state-storage-edelic"
    key     = "global/s3/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}

provider "aws" {
  region = "eu-central-1" # Enforcing the EU Sovereign Boundary
}

variable "aws_account_id" {
  type      = string
  sensitive = true
}

# 1. Include the API Gateway Module
module "api" {
  source     = "./aws/api"
  lambda_uri = module.green_logistics_lambda.invoke_arn 
}

# 2. Include the Lambda Module
module "green_logistics_lambda" {
  source           = "./aws/lambda/green-logistics-optimizer-lambda-edelic"
  aws_account_id   = var.aws_account_id
  api_id           = module.api.api_id
  root_resource_id = module.api.root_resource_id
}

# 3. Output the final endpoint
output "final_api_endpoint" {
  value       = module.api.invoke_url
  description = "The public URL to trigger the Green Logistics Optimizer"
}