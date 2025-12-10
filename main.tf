module "static_site" {
  source = "./modules/static-site"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }
  project_name = var.project_name
  domain_name  = var.domain_name
}

module "database" {
  source = "./modules/database"
  providers = {
    aws.primary = aws.primary
  }
  project_name     = var.project_name
  primary_region   = var.primary_region
  secondary_region = var.secondary_region
}

module "networking" {
  source = "./modules/networking"
  providers = {
    aws.primary = aws.primary
  }
  project_name              = var.project_name
  domain_name               = var.domain_name
  primary_bucket_endpoint   = module.static_site.primary_bucket_website_endpoint
  primary_bucket_zone_id    = module.static_site.primary_bucket_hosted_zone_id
  secondary_bucket_endpoint = module.static_site.secondary_bucket_website_endpoint
  secondary_bucket_zone_id  = module.static_site.secondary_bucket_hosted_zone_id
}

