terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Creates a zip file to upload for our lambda function
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lab1_lambda_function.py"
  output_path = "${path.module}/files/lambdafunction.zip"
}

# Create an S3 bucket
resource "aws_s3_bucket" "lab1_s3_bucket" {
  bucket = "lab1-s3-bucket"
  tags = {
    Name        = "lab1-s3-bucket"
    Environment = "Dev"
  }
}

# Create role and policy for the lambda
resource "aws_iam_role" "lab1_lambda_function_role" {
  name = "lab1-lambda-function-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lab1_lambda_function_role_policy" {
  name   = "lab1-lambda-function-role-policy"
  role   = aws_iam_role.lab1_lambda_function_role.id
  policy = "${file("policy.json")}"
}

# Create the lambda function
resource "aws_lambda_function" "lab1_lambda_function" {
  filename         = "lambdafunction.zip"
  function_name    = "lab1-lambda-function"
  role             = aws_iam_role.lab1_lambda_function_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 3
  memory_size      = 128
  source_code_hash = data.archive_file.lambda.output_base64sha256
  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.lab1_s3_bucket.id
    }
  }
}

# Create permissions for the S3 bucket to invoke our lambda
resource "aws_lambda_permission" "lab1_lambda_function_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lab1_lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lab1_s3_bucket.arn
}

# Create S3 bucket notification when a json object with name "input.json" is created
resource "aws_s3_bucket_notification" "lab1_s3_bucket_notification" {
  bucket = aws_s3_bucket.lab1_s3_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.lab1_lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }
}
