data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.primary.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    resources = ["${aws_s3_bucket.primary.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]
    resources = ["${aws_s3_bucket.secondary.arn}/*"]
  }
}

resource "aws_iam_role" "replication" {
  provider = aws.primary
  name     = "${var.project_name}-replication-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "replication" {
  provider = aws.primary
  name     = "${var.project_name}-replication-policy"
  policy   = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  provider   = aws.primary
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

resource "aws_s3_bucket_replication_configuration" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  role     = aws_iam_role.replication.arn

  rule {
    id     = "replication-rule"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.secondary.arn
      storage_class = "STANDARD"
    }
  }
  depends_on = [aws_s3_bucket_versioning.primary, aws_s3_bucket_versioning.secondary]
}

resource "aws_s3_bucket_website_configuration" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_website_configuration" "secondary" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_public_access_block" "secondary" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  policy   = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.primary.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.primary]
}

resource "aws_s3_bucket_policy" "secondary" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary.id
  policy   = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.secondary.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.secondary]
}

