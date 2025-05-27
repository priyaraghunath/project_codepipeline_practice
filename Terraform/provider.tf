// provider.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "bucketforlogstrore-bootcampproject"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "Terraform-Logstor"
    encrypt        = true
  }
}

# Default provider (fallback to region1)
provider "aws" {
  region = var.region1
}

# Aliased providers
provider "aws" {
  alias  = "region1"
  region = var.region1
}

provider "aws" {
  alias  = "region2"
  region = var.region2
}
