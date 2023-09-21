terraform {
  backend "s3" {
    bucket = "tf-state-033818603844"
    key    = "production/terraform.tfstate"
    region = "us-east-1"

    # metadata = {
    #   "Content-Type" = "text/css"
    # }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_route53_record" "production" {
  zone_id = "Z03125721OO6DLH9254P2"
  name    = "textatow.com"
  type    = "A"
  alias {
    name                   = aws_alb.production_main.dns_name
    zone_id                = aws_alb.production_main.zone_id
    evaluate_target_health = true
  }
}