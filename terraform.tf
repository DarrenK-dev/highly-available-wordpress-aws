terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-state-bucket-darrenk.dev"
    key     = "highly-available-wordpress-aws/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}


provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}



