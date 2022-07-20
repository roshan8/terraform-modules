resource "aws_s3_bucket_acl" "aaps_acl" {
  bucket = aws_s3_bucket.aaps_pppp_lambda_bucket.id
  acl    = var.acl
}

resource "aws_s3_bucket_versioning" "aaps_versioning" {
  bucket = aws_s3_bucket.aaps_pppp_lambda_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "aaps_pppp_lambda_bucket" {
  bucket = var.bucket
  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
  bucket = aws_s3_bucket.aaps_pppp_lambda_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    Id = "LAMBDABUCKETPOLICY"
    "Statement" : [
      {
        "Sid" : "crossaccountS3Access",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.arn}"
        },
        "Action" : [
          "s3:GetBucketLocation",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket}",
          "arn:aws:s3:::${var.bucket}/*"
        ]
      }
    ]
  })
}

