provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "eks-observability-platform"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
