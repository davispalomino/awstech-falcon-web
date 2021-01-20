resource "aws_s3_bucket" "this" {
  bucket        = "${var.project}-${var.env}-${var.service}"
  acl           = "private"
  force_destroy = true
    
  versioning {
    enabled = false
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  
  tags = {
      Service = var.service
      Project = var.project
      Env     = var.env
  }
}

data "aws_iam_policy_document" "this" {
  statement {

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}

resource "null_resource" "this" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "aws s3 sync ../app/ s3://$AWS_BUCKET/ --region $AWS_REGION --delete --exclude '*.scannerwork/*' --exclude '*.sonar/*'"
    environment = {
        AWS_REGION = us-east-1
        AWS_BUCKET = aws_s3_bucket.this.id
    }
  }
}