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

variable "reader_principals" {
  description = "List of principals (e.g. service accounts) that should have reader access to the repository."
  type        = list(string)
  default     = []
}
