terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [ aws.primary, aws.secondary ]
    }
  }
}

resource "aws_s3_bucket" "primary" {
  provider = aws.primary
  bucket   = "${var.project_name}-primary-${var.domain_name}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "secondary" {
  provider = aws.secondary
  bucket   = "${var.project_name}-secondary-${var.domain_name}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "secondary" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "index" {
  provider     = aws.primary
  bucket       = aws_s3_bucket.primary.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}
