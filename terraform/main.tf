terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
# Terraform is reading from my environment variables to get the
# access key and secret access key and region
provider "aws" {}

data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

# Creates a zip file to upload for our lambda function
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../${path.module}/lambdas/lab1_lambda_function.py"
  output_path = "../${path.module}/lambdas/lambdafunction.zip"
}
