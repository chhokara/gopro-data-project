variable "project_id" {
  description = "The ID of the project in which to create the Cloud Run Job."
  type        = string
}

variable "region" {
  description = "The region in which to create the Cloud Run Job."
  type        = string
}

variable "service_account_id" {
  description = "The ID of the service account to be created for the Cloud Run Job."
  type        = string
}

variable "job_name" {
  description = "The name of the Cloud Run Job."
  type        = string
}

variable "container_image" {
  description = "The container image to be used for the Cloud Run Job."
  type        = string
}

variable "curated_bucket" {
  description = "The name of the curated GCS bucket."
  type        = string
}

variable "out_prefix" {
  description = "The output prefix for the Cloud Run Job."
  type        = string
}

variable "invoker_member" {
  description = "The member (user, service account, etc.) to be granted the Cloud Run Job invoker role."
  type        = string
}