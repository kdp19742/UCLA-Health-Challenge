# IAM policy for lambda
data "aws_iam_policy_document" "example" {
  statement {
    sid = "S3GetObjectPolicy"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.lab1_s3_bucket.arn}/*"
    ]
  }

  statement {
    sid = "BatchSubmitJobPolicy"

    actions = [
      "batch:SubmitJob"
    ]

    resources = [
      "arn:aws:batch:us-west-2:${local.account_id}:job-definition/lab1-def:8",
      "arn:aws:batch:us-west-2:${local.account_id}:job-queue/lab1-queue"
    ]
  }

  statement {
    sid = "LambdaCloudwatchPolicy"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.lambda_log_group.arn
    ]
  }

  statement {
    sid = "LambdaExecutePolicy"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [
      "${aws_lambda_function.lab1_lambda_function.arn}:*"
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        aws_s3_bucket.lab1_s3_bucket.arn
      ]
    }
  }
}

# Policy for S3 bucket to allow lambda to get an object
data "aws_iam_policy_document" "example1" {
  statement {
    sid = "AllowS3Access"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:role/${aws_iam_role.lab1_lambda_function_role.id}"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.lab1_s3_bucket.arn,
      "${aws_s3_bucket.lab1_s3_bucket.arn}/*",
    ]
  }
}
