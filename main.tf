terraform {
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
  region = "eu-central-1"
}

# --- Root Variables ---

variable "aws_account_id" {
  type      = string
  sensitive = true
}

variable "poly_api_key" {
  type      = string
  sensitive = true
}

# This captures the timestamped zip name from the GitHub Action -var flag
variable "lambda_zip_path" {
  type        = string
  description = "The dynamic name of the generated Lambda deployment package"
  default     = "optimizer.zip"
}

# --- Module Orchestration ---

module "api" {
  source     = "./aws/api"
  lambda_uri = module.green_logistics_lambda.invoke_arn 
}

module "green_logistics_lambda" {
  source           = "./aws/lambda/green-logistics-optimizer-lambda-edelic"
  aws_account_id   = var.aws_account_id
  api_id           = module.api.api_id
  root_resource_id = module.api.root_resource_id
  poly_api_key     = var.poly_api_key
  
  # Passing the zip path down to the module
  lambda_zip_path  = var.lambda_zip_path
}

# --- Outputs ---

output "final_api_endpoint" {
  value       = module.api.invoke_url
  description = "The public URL to trigger the Green Logistics Optimizer"
}