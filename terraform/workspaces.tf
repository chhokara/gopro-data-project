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

resource "tfe_organization" "gopro-data-org" {
    name = "gopro-data-org"
    email = var.tfc_email
}

resource "tfe_oauth_client" "github-oauth-client" {
    organization = tfe_organization.gopro-data-org.name
    api_url = "https://api.github.com"
    http_url = "https://github.com"
    oauth_token = var.github_oauth_token_id
    service_provider = "github"
}

resource "tfe_workspace" "gopro-data-workspace" {
    name = "gopro-data-workspace"
    organization = tfe_organization.gopro-data-org.name
    queue_all_runs = false
    vcs_repo {
        branch = "main"
        identifier = "chhokara/gopro-data-project"
        oauth_token_id = tfe_oauth_client.github-oauth-client.oauth_token
    }
}