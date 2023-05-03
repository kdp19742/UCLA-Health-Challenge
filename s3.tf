# Create an S3 bucket
# Letting AWS create a random name because the name lab1-s3-bucket was taken
# and I didn't know what other name to use
resource "aws_s3_bucket" "lab1_s3_bucket" {
  tags = {
    Name        = "lab1-s3-bucket"
    Environment = "Dev"
  }
}

# S3 bucket policy allows lambda to access the bucket
resource "aws_s3_bucket_policy" "lab1_s3_bucket_policy" {
  bucket = aws_s3_bucket.lab1_s3_bucket.id
  policy = data.aws_iam_policy_document.example1.json
}

# Found this on stack overflow to help waiting for s3 bucket creation
resource "null_resource" "wait_for_lambda_trigger" {
  depends_on = [aws_lambda_permission.lab1_lambda_function_permission]
  
  provisioner "local-exec" {
    command = "sleep 1m"
  }
}

# Create S3 bucket notification when a json object with name "input.json" is created
resource "aws_s3_bucket_notification" "lab1_s3_bucket_notification" {
  bucket = aws_s3_bucket.lab1_s3_bucket.id
  
  lambda_function {
    lambda_function_arn = aws_lambda_function.lab1_lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  # S3 bucket takes some time to create so we need to wait or else we fail
  depends_on = [null_resource.wait_for_lambda_trigger]
}
