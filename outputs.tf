output "app_blue_url" {
  value = local.deploy_blue ? "https://${module.service_blue.0.service_url}" : null
}

output "custom_blue_url" {
  value = local.deploy_blue && local.domain_name != null ? "https://blue.${local.domain_name}" : null
}

output "app_green_url" {
  value = local.deploy_green ? "https://${module.service_green.0.service_url}" : null
}

output "custom_green_url" {
  value = local.deploy_green && local.domain_name != null ? "https://green.${local.domain_name}" : null
}

output "custom_domain_url" {
  value = local.domain_name != null ? "https://${local.domain_name}" : null
}
