variable "project_id" {
  description = "The ID of the project in which to create the Artifact Registry repository."
  type        = string
}

variable "region" {
  description = "The region in which to create the Artifact Registry repository."
  type        = string
}

variable "repository_id" {
  description = "The ID of the Artifact Registry repository."
  type        = string
}

variable "composer_sa_email" {
  description = "The service account email used by Cloud Composer."
  type        = string
}