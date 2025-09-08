terraform {
    required_providers {
        tfe = {
            source  = "hashicorp/tfe"
            version = "~> 0.50"
        }
    }
}

provider "tfe" {
    token = var.tfc_api_token
}

resource "tfe_workspace" "gopro_data_project" {
    name         = "gopro-data-project"
    organization = "gopro-data-project"
    description  = "A workspace for the GoPro Data Project"
}