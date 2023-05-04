variable "dream_env" {
  description = "dream app environment variables to set"
  type        = any
  default     = {}
}

variable "dream_project_dir" {
  description = "root directory of the project sources"
  type        = string
}

variable "source_bucket" {
  description = "bucket to store the source code in"
  type        = string
}

variable "service_port" {
  description = "port to expose the service on"
  type        = number
  default     = 8080
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
  default     = "gcr.io/buildpacks/builder:v1"
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

