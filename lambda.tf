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
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "lab1-lambda-function-role"
    Environment = "Dev"
  }
}

resource "aws_iam_role_policy" "lab1_lambda_function_role_policy" {
  name   = "lab1-lambda-function-role-policy"
  role   = aws_iam_role.lab1_lambda_function_role.id
  policy = data.aws_iam_policy_document.example.json
}

# Create the lambda function
resource "aws_lambda_function" "lab1_lambda_function" {
  filename         = "lambdafunction.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lab1_lambda_function_role.arn
  handler          = "lab1_lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 3
  memory_size      = 128
  source_code_hash = data.archive_file.lambda.output_base64sha256

  tags = {
    Name        = "lab1-lambda-function"
    Environment = "Dev"
  }
}

# Create cloudwatch log group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 365

  tags = {
    Environment = "Dev"
    Function    = var.lambda_function_name
  }
}

# Create lambda permissions for the S3 bucket to invoke our lambda
resource "aws_lambda_permission" "lab1_lambda_function_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lab1_s3_bucket.arn
}