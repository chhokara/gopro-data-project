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
data "tfe_github_installation" "this" {
    name = "chhokara"
}

resource "tfe_workspace" "gopro_data_project" {
    name         = "gopro-data-project"
    organization = "gopro-data-project"
    description  = "A workspace for the GoPro Data Project"

    vcs_repo {
        identifier     = "chhokara/gopro-data-project"
        branch         = "main"
        github_app_installation_id = data.tfe_github_installation.this.id
        ingress_submodules = false
    }
}