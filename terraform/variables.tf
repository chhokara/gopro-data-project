variable tfc_api_token {
    description = "Terraform Cloud API token"
    type        = string
    sensitive   = true
}

variable tfc_email {
    description = "Terraform Cloud Email"
    type        = string
}

variable github_oauth_token_id {
    description = "GitHub OAuth Token"
    type        = string
    sensitive   = true
}