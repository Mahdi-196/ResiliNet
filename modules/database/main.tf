terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [ aws.primary, aws.secondary ]
    }
  }
}

resource "aws_dynamodb_table" "global_table" {
  provider         = aws.primary
  name             = "${var.project_name}-users"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  hash_key         = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  replica {
    region_name = var.primary_region
  }

  replica {
    region_name = var.secondary_region
  }
}

