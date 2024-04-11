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

resource "aws_s3_bucket" "videorec" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "prod"
  }
}

resource "aws_s3_bucket_acl" "videorec_acl" {
  bucket = aws_s3_bucket.videorec.id
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "videorec_public_access_block" {
  bucket = aws_s3_bucket.videorec.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "videorec_bucket_policy" {
  bucket = aws_s3_bucket.videorec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action    = "s3:GetObject"
        Effect    = "Allow"
        Resource  = "${aws_s3_bucket.videorec.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "videorec_website_configuration" {
  bucket = aws_s3_bucket.videorec.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_object" "videorec_source_files" {
  bucket = aws_s3_bucket.videorec.id

  for_each = fileset("../build", "**/*")

  key    = each.value
  source = "../build/${each.value}"
}
