variable "name" {
  type        = string
  description = "Name of the service"
}

variable "service_port" {
  description = "Port on which the service is listening"
}

variable "env" {
  description = "Environment variables of the service"
  type        = map(string)
}

variable "secrets" {
  description = "Secrets of the service"
  type        = map(string)
}

variable "image_identifier" {
  description = "Docker Image identifier from ECR"
}

variable "access_role_arn" {
  description = "App Runner access role ARN"
}

variable "instance_role_arn" {
  description = "App Runner instance role ARN"
}

variable "auto_scaling_configuration_arn" {
  description = "App Runner auto scaling configuration ARN"
}
