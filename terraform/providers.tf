terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    mysql = {
      source  = "petoju/mysql"
      version = ">= 3.0.82"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
}
