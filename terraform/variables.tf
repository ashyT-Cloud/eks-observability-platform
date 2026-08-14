variable "aws_region" {
  description = "AWS region where the platform will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name used for resource tagging."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "eks-observability-platform"
}
