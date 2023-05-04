locals {
  domain_name                    = var.domain_prefix != null && var.domain_suffix != null ? "${var.domain_prefix}.${var.domain_suffix}" : null
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
  count   = local.domain_name != null ? 1 : 0
  zone_id = data.aws_route53_zone.domain[0].zone_id
  name    = local.domain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_apprunner_custom_domain_association.app.0.dns_target]
}


resource "aws_route53_record" "app_certificate_validation" {
  count   = local.domain_name != null ? 3 : 0
  zone_id = data.aws_route53_zone.domain[0].zone_id
  name    = element(local.certificate_validation_records, count.index).name
  type    = element(local.certificate_validation_records, count.index).type
  ttl     = 300
  records = [element(local.certificate_validation_records, count.index).value]
}
