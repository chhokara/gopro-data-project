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

variable "airflow_url" {
  description = "Base URL of the Airflow instance (e.g. http://34.x.x.x:8080)"
  type        = string
}

variable "airflow_username" {
  description = "Airflow REST API username"
  type        = string
}

variable "airflow_password" {
  description = "Airflow REST API password"
  type        = string
  sensitive   = true
}