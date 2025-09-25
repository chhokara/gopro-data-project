terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.50"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "gopro-data-org"

    workspaces {
      name = "gopro-data-workspace"
    }
  }
}

provider "tfe" {
  token = var.tfc_api_token
}

provider "aws" {
  region = var.aws_region
}