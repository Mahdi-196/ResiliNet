output "primary_bucket_website_endpoint" {
  value = aws_s3_bucket_website_configuration.primary.website_endpoint
}

output "primary_bucket_hosted_zone_id" {
  value = aws_s3_bucket.primary.hosted_zone_id
}

output "secondary_bucket_website_endpoint" {
  value = aws_s3_bucket_website_configuration.secondary.website_endpoint
}

output "secondary_bucket_hosted_zone_id" {
  value = aws_s3_bucket.secondary.hosted_zone_id
}
