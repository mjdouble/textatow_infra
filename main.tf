terraform {
  backend "s3" {
    bucket = "tf-state-033818603844"
    key    = "staging/terraform.tfstate"
    region = "us-east-1"
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

resource "aws_route53_record" "staging" {
  zone_id = "Z03125721OO6DLH9254P2"
  name    = "staging.textatow.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_alb.main.dns_name]
  }
