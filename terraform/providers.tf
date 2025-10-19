terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.50"
    }
    google = {
      source  = "hashicorp/google"
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

provider "google" {
  project = env("GCP_CLOUD_PROJECT")
  region  = env("GOOGLE_REGION") 
  zone    = env("GOOGLE_ZONE")
  credentials = base64decode(env("GOOGLE_CREDENTIALS_BASE64"))
}