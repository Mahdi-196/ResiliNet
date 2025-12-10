output "website_url" {
  value = "http://${var.domain_name}"
}

output "primary_bucket_endpoint" {
  value = module.static_site.primary_bucket_website_endpoint
}

output "secondary_bucket_endpoint" {
  value = module.static_site.secondary_bucket_website_endpoint
}

output "dynamodb_table_name" {
  value = module.database.table_name
}

