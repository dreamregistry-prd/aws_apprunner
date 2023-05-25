terraform {
  #  backend "s3" {}
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
  domain_name = var.domain_prefix != null && var.domain_suffix != null ? "${var.domain_prefix}.${var.domain_suffix}" : null

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

  deploy_new_version = var.enable_blue_green ? var.deploy_new_version : false
  deploy_blue        = var.live_version == "blue" || (var.enable_blue_green && local.deploy_new_version)
  deploy_green       = var.live_version == "green" || (var.enable_blue_green && local.deploy_new_version)
  new_version        = var.live_version == "blue" ? "green" : "blue"
  image_tags         = var.enable_blue_green && local.deploy_new_version ? [local.new_version] : [
    var.live_version
  ]
}

module "docker_build" {
  source    = "github.com/hereya/terraform-modules//docker-build/module?ref=v0.20.0"
  providers = {
    aws.us-east-1 = aws.us-east-1
  }
  source_dir              = var.dream_project_dir
  image_tags              = local.image_tags
  image_name              = var.image_name
  builder                 = var.builder
  force_delete_repository = var.force_delete_repository
  codecommit_password_key = var.codecommit_password_key
  codecommit_username     = var.codecommit_username
}

module "domain_live" {
  count         = local.domain_name != null ? 1 : 0
  source        = "./modules/custom-domain/module"
  domain_name   = local.domain_name
  domain_suffix = var.domain_suffix
  service_arn   = var.live_version == "blue" ? module.service_blue.0.arn : module.service_green.0.arn
}


module "service_blue" {
  count                          = local.deploy_blue ? 1 : 0
  source                         = "./modules/service/module"
  access_role_arn                = aws_iam_role.app_runner.arn
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app.arn
  env                            = local.env
  image_identifier               = "${module.docker_build.repository_url}:blue"
  instance_role_arn              = aws_iam_role.instance.arn
  name                           = "${local.name}-blue"
  secrets                        = local.secrets
  service_port                   = var.service_port
  depends_on                     = [module.docker_build]
}

module "domain_blue" {
  count         = local.domain_name != null && local.deploy_blue ? 1 : 0
  source        = "./modules/custom-domain/module"
  domain_name   = "blue.${local.domain_name}"
  domain_suffix = var.domain_suffix
  service_arn   = module.service_blue.0.arn
}


module "service_green" {
  count                          = local.deploy_green ? 1 : 0
  source                         = "./modules/service/module"
  access_role_arn                = aws_iam_role.app_runner.arn
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app.arn
  env                            = local.env
  image_identifier               = "${module.docker_build.repository_url}:green"
  instance_role_arn              = aws_iam_role.instance.arn
  name                           = "${local.name}-green"
  secrets                        = local.secrets
  service_port                   = var.service_port
  depends_on                     = [module.docker_build]
}

module "domain_green" {
  count         = local.domain_name != null && local.deploy_green ? 1 : 0
  source        = "./modules/custom-domain/module"
  domain_name   = "green.${local.domain_name}"
  domain_suffix = var.domain_suffix
  service_arn   = module.service_green.0.arn
}

resource "aws_apprunner_auto_scaling_configuration_version" "app" {
  auto_scaling_configuration_name = substr(local.name, 0, 32)
  max_concurrency                 = 100
  min_size                        = var.min_replicas
  max_size                        = var.max_replicas

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
  count  = length(local.secrets) > 0 ? 1 : 0
  policy = data.aws_iam_policy_document.instance.0.json
}

resource "aws_iam_role_policy_attachment" "instance" {
  count      = length(local.secrets) > 0 ? 1 : 0
  policy_arn = aws_iam_policy.instance.0.arn
  role       = aws_iam_role.instance.name
}


