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

variable "live_version" {
  type        = string
  description = "The version of the service to deploy to set as live: blue or green"
  default     = "blue"
}

variable "enable_blue_green" {
  type        = bool
  description = "If true, the service will be deployed using blue/green deployment"
  default     = false
}

variable "deploy_new_version" {
  type        = bool
  description = "If true, the old version of the service will be destroyed on deploy. Is set to true if enable_blue_green is false"
  default     = false
}