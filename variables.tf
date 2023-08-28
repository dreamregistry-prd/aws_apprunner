variable "dream_env" {
  description = "dream app environment variables to set"
  type        = any
  default     = {}
}

variable "dream_project_dir" {
  description = "root directory of the project sources"
  type        = string
}

variable "codecommit_password_key" {
  description = "The name of the key in SSM Parameter Store that contains the CodeCommit password"
}

variable "codecommit_username" {
  description = "The username to use when authenticating to CodeCommit"
}


variable "service_port" {
  description = "port to expose the service on"
  type        = number
  default     = 8080
}

variable "min_replicas" {
  default     = 1
  type        = number
  description = "minimum number of replicas to run"
}

variable "max_replicas" {
  default     = 3
  type        = number
  description = "maximum number of replicas to run"
}

variable "image_name" {
  description = "name of the docker image to build without the namespace. Uses the project dir name by default"
  type        = string
  default     = null
}

variable "image_tags" {
  description = "tag of the docker image to build"
  type        = list(string)
  default     = null
}

variable "builder" {
  description = "buildpack builder to use to build the docker image"
  type        = string
  default     = "heroku/builder:22"
}

variable "force_delete_repository" {
  description = "If true, the ECR repository will be deleted on destroy even if it contains images"
  type        = bool
  default     = true
}

variable "domain_prefix" {
  description = "domain prefix to use for the service"
  type        = string
  default     = null
}

variable "domain_suffix" {
  description = "domain suffix to use for the service"
  type        = string
  default     = null
}

variable "is_private_domain" {
  description = "Whether the Route53 zone is private or not"
  type        = bool
  default     = false
}

variable "public_domain_suffix" {
  type        = string
  description = "The public domain suffix used in case domain_suffix is private. For now this package only work with public domain."
  default     = null
}

variable "use_apex_domain" {
  description = "If true, the service will be exposed on the apex domain"
  type        = bool
  default     = false
}

variable "apprunner_zone_id" {
  description = "Aws Apprunner Route 53 Hosted Zone ID to use for alias records"
  type        = string
  default     = null
}

variable "dockerhub_username" {
  description = "The username to use when authenticating to the docker registry"
}

variable "dockerhub_password" {
  sensitive   = true
  description = "The password to use when authenticating to the docker registry"
}