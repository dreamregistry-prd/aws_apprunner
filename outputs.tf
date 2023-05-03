output "app_url" {
  value = "https://${aws_apprunner_service.app.service_url}"
}
