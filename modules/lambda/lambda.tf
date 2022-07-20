resource "aws_iam_role" "aaps_pppp_lambda_role" {
  name        = var.lambda_role
  description = "IAM role for a aaps_pppp_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "aaps_pppp_lambda_policy" {
  name = var.lambda_policy
  role = aws_iam_role.aaps_pppp_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_AmazonS3ObjectLambdaExecution" {
  role       = aws_iam_role.aaps_pppp_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonS3ObjectLambdaExecutionRolePolicy"
}

#######################################
# Lambda function & s3 Buket creation
#######################################
resource "aws_lambda_function" "aaps_pppp_lambda_function" {
  filename      = var.filename
  function_name = var.function_name
  description   = "Lambda function for customer-insight project"
  # s3_bucket     = aws_s3_bucket_object.upload_lambdafile.bucket # only when s3 is used
  # s3_key        = aws_s3_bucket_object.upload_lambdafile.key # only when s3 is used
  memory_size      = 1024
  timeout          = 300
  runtime          = var.runtime
  role             = aws_iam_role.aaps_pppp_lambda_role.arn
  source_code_hash = base64sha256(var.filename)
  handler          = var.handler
  # layers = ["${aws_lambda_layer_version.cassandra-driver.arn}",
  #   "${aws_lambda_layer_version.pandas.arn}",
  # "${aws_lambda_layer_version.keyspaces.arn}"]

  # TODO: Best practice
  #vpc_config {
  #subnet_ids         = var.subnets
  #security_group_ids = var.security_groups
  #}
  timeouts {
    create = "30m"
  }
  # tags = {
  #   env = var.stage_name
  # }
  # environment {
  #   variables = {
  #     env                = "${var.stage_name}",
  #     queue_name         = "${var.sqs_queue_name}"
  #     aws_account_number = "${var.aws_account_number}"
  #   }
  # }
}


