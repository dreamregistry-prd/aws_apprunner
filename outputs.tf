output "app_url" {
  value = "https://${aws_apprunner_service.app.service_url}"
}

output "custom_domain_url" {
  value = local.domain_name != null ? "https://${local.domain_name}" : null
}
