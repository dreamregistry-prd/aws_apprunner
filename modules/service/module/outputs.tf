output "arn" {
  value = aws_apprunner_service.app.arn
}

output "service_url" {
  value = aws_apprunner_service.app.service_url
}