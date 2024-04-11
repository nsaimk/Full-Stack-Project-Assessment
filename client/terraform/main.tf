terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "videorec-s3" {
  bucket = var.bucket_name



  tags = {
    Name        = var.bucket_name
    Environment = "prod"
  }
}

resource "aws_s3_bucket_acl" "videorec-s3_acl" {
  bucket = aws_s3_bucket.videorec-s3.id
  acl    = "public-read"
}




resource "aws_s3_bucket_public_access_block" "videorec-s3_public_access_block" {
  bucket = aws_s3_bucket.videorec-s3.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "hosting_bucket_policy" {
  bucket = aws_s3_bucket.videorec-s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },

    ]
  })

}

resource "aws_s3_bucket_website_configuration" "hosting_bucket_website_configuration" {
  bucket = aws_s3_bucket.videorec-s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_object" "source_files" {
    bucket = aws_s3_bucket.videorec-s3.id

    for_each = fileset("../build", "**/*")

    key          = each.value
    source       = "../build/${each.value}"
}