variable "tfc_api_token" {
  description = "Terraform Cloud API token"
  type        = string
  sensitive   = true
}

variable "tfc_email" {
  description = "Terraform Cloud Email"
  type        = string
}

variable "github_oauth_token_id" {
  description = "GitHub OAuth Token"
  type        = string
  sensitive   = true
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
}

variable "gcp_zone" {
  description = "GCP Zone"
  type        = string
}

variable "gcp_credentials_base64" {
  description = "Base64 encoded GCP credentials JSON"
  type        = string
  sensitive   = true
}