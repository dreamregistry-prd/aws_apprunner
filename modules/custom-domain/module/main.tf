terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  certificate_validation_records = tolist(
    aws_apprunner_custom_domain_association.app.certificate_validation_records
  )
}

resource "aws_apprunner_custom_domain_association" "app" {
  domain_name = var.domain_name
  service_arn = var.service_arn
}

data "aws_route53_zone" "domain" {
  name = var.domain_suffix
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_apprunner_custom_domain_association.app.dns_target]
}


resource "aws_route53_record" "app_certificate_validation" {
  count   = 3
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = element(local.certificate_validation_records, count.index).name
  type    = element(local.certificate_validation_records, count.index).type
  ttl     = 300
  records = [element(local.certificate_validation_records, count.index).value]
}