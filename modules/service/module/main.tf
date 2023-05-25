terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_apprunner_service" "app" {
  service_name = var.name

  auto_scaling_configuration_arn = var.auto_scaling_configuration_arn

  source_configuration {
    image_repository {
      image_configuration {
        port                          = var.service_port
        runtime_environment_variables = var.env
        runtime_environment_secrets   = var.secrets
      }
      image_identifier      = var.image_identifier
      image_repository_type = "ECR"
    }
    authentication_configuration {
      access_role_arn = var.access_role_arn
    }
    auto_deployments_enabled = true
  }

  instance_configuration {
    instance_role_arn = var.instance_role_arn
  }

  tags = {
    Name = var.name
  }
}