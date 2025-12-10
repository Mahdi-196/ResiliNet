terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [ aws.primary ]
    }
  }
}

data "aws_route53_zone" "main" {
  provider = aws.primary
  name     = var.domain_name
}

resource "aws_route53_health_check" "primary" {
  provider          = aws.primary
  fqdn              = var.primary_bucket_endpoint
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name = "${var.project_name}-primary-health-check"
  }
}

resource "aws_route53_record" "primary" {
  provider = aws.primary
  zone_id  = data.aws_route53_zone.main.zone_id
  name     = var.domain_name
  type     = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "primary"
  health_check_id = aws_route53_health_check.primary.id

  alias {
    name                   = var.primary_bucket_endpoint
    zone_id                = var.primary_bucket_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "secondary" {
  provider = aws.primary
  zone_id  = data.aws_route53_zone.main.zone_id
  name     = var.domain_name
  type     = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "secondary"

  alias {
    name                   = var.secondary_bucket_endpoint
    zone_id                = var.secondary_bucket_zone_id
    evaluate_target_health = false
  }
}
