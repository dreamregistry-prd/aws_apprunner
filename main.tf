terraform {
  backend "s3" {}
  required_version = ">= 1.0.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {}
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

locals {
  name           = module.docker_build.image_name
  non_secret_env = {
    for k, v in var.dream_env : k => try(tostring(v), null)
  }
  secret_env = {
    for k, v in var.dream_env : k => try(tostring(v.arn), null)
  }

  env = merge({
    PORT = var.service_port
  }, {
    for k, v in local.non_secret_env : k => v if v != null
  })
  secrets = {
    for k, v in local.secret_env : k => v if v != null
  }
}

module "docker_build" {
  source    = "github.com/hereya/terraform-modules//docker-build/module?ref=v0.5.0"
  providers = {
    aws.us-east-1 = aws.us-east-1
  }
  source_dir              = var.dream_project_dir
  source_bucket           = var.source_bucket
  image_tags              = var.image_tags
  image_name              = var.image_name
  builder                 = var.builder
  force_delete_repository = var.force_delete_repository
}


resource "aws_apprunner_service" "app" {
  service_name = local.name

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app.arn

  source_configuration {
    image_repository {
      image_configuration {
        port                          = var.service_port
        runtime_environment_variables = local.env
        runtime_environment_secrets   = local.secrets
      }
      image_identifier      = module.docker_build.images[0]
      image_repository_type = "ECR"
    }
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner.arn
    }
    auto_deployments_enabled = true
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.instance.arn
  }


  tags = {
    Name = local.name
  }

  depends_on = [module.docker_build]
}

resource "aws_apprunner_auto_scaling_configuration_version" "app" {
  auto_scaling_configuration_name = substr(local.name, 0, 32)
  max_concurrency                 = 100
  max_size                        = 3
  min_size                        = 1

  tags = {
    Name = "${local.name}-auto-scaling-configuration"
  }
}

data "aws_iam_policy_document" "app_runner_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [
        "build.apprunner.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "app_runner" {
  name               = "${local.name}-app-runner-role"
  assume_role_policy = data.aws_iam_policy_document.app_runner_assume.json
}

resource "aws_iam_role_policy_attachment" "app_runner" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
  role       = aws_iam_role.app_runner.name
}

data "aws_iam_policy_document" "instance_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [
        "tasks.apprunner.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "${local.name}-instance-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume.json
}

data "aws_iam_policy_document" "instance" {
  count = length(local.secrets) > 0 ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = [
      for k, v in local.secrets : v
    ]
  }
}

resource "aws_iam_policy" "instance" {
  count = length(local.secrets) > 0 ? 1 : 0
  policy = data.aws_iam_policy_document.instance.0.json
}

resource "aws_iam_role_policy_attachment" "instance" {
  count = length(local.secrets) > 0 ? 1 : 0
  policy_arn = aws_iam_policy.instance.0.arn
  role       = aws_iam_role.instance.name
}


