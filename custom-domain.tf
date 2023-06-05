locals {
  apex_domain_name               = var.use_apex_domain && var.domain_prefix == null && var.domain_suffix != null && var.apprunner_zone_id != null ? var.domain_suffix : null
  subdomain_name                 = var.domain_prefix != null && var.domain_suffix != null ? "${var.domain_prefix}.${var.domain_suffix}" : null
  domain_name                    = local.subdomain_name != null ? local.subdomain_name : (local.apex_domain_name != null ? local.apex_domain_name : null)
  certificate_validation_records = local.domain_name != null ? tolist(
    aws_apprunner_custom_domain_association.app.0.certificate_validation_records
  ) : []
}

resource "aws_apprunner_custom_domain_association" "app" {
  count       = local.domain_name != null ? 1 : 0
  domain_name = local.domain_name
  service_arn = aws_apprunner_service.app.arn
}

data "aws_route53_zone" "domain" {
  count = local.domain_name != null ? 1 : 0
  name  = var.domain_suffix
}

resource "aws_route53_record" "app" {
  count   = local.subdomain_name != null ? 1 : 0
  zone_id = data.aws_route53_zone.domain[0].zone_id
  name    = local.subdomain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_apprunner_custom_domain_association.app.0.dns_target]
}

resource "aws_route53_record" "app_alias" {
  count   = local.apex_domain_name != null ? 1 : 0
  name    = local.apex_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.domain[0].zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_apprunner_custom_domain_association.app.0.dns_target
    zone_id                = var.apprunner_zone_id
  }
}

resource "aws_route53_record" "app_www_alias" {
  count   = local.apex_domain_name != null ? 1 : 0
  name    = "www.${local.apex_domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.domain[0].zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_apprunner_custom_domain_association.app.0.dns_target
    zone_id                = var.apprunner_zone_id
  }
}

resource "aws_route53_record" "app_certificate_validation" {
  count   = local.domain_name != null ? 3 : 0
  zone_id = data.aws_route53_zone.domain[0].zone_id
  name    = element(local.certificate_validation_records, count.index).name
  type    = element(local.certificate_validation_records, count.index).type
  ttl     = 300
  records = [element(local.certificate_validation_records, count.index).value]
}
