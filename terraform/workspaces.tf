data "tfe_organization" "gopro-data-org" {
  name = "gopro-data-org"
}

resource "tfe_workspace" "gopro-data-workspace" {
  name              = "gopro-data-workspace"
  description       = "Workspace for GoPro Data Project"
  organization      = data.tfe_organization.gopro-data-org.name
  queue_all_runs    = false
  working_directory = "./terraform"
  auto_apply        = true
  vcs_repo {
    branch         = "main"
    identifier     = "chhokara/gopro-data-project"
    oauth_token_id = var.github_oauth_token_id
  }
}
