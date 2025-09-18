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

data "tfe_organization" "gopro-data-org" {
    name = "gopro-data-org"
}

## trigger run
resource "tfe_workspace" "gopro-data-workspace" {
    name = "gopro-data-workspace"
    organization = data.tfe_organization.gopro-data-org.name
    queue_all_runs = false
    working_directory = "./terraform"
    auto_apply = true
    vcs_repo {
        branch = "main"
        identifier = "chhokara/gopro-data-project"
        oauth_token_id = var.github_oauth_token_id
    }
}