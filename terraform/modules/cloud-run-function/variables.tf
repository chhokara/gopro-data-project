variable "project_id" {
  description = "The ID of the project in which the function will be created."
  type        = string
}

variable "region" {
  description = "The region where the function will be deployed."
  type        = string
  default     = "us-central1"
}

variable "name" {
  description = "The name of the Cloud Run Function."
  type        = string
}

variable "runtime" {
  description = "The runtime for the function (e.g. python312)."
  type        = string
}

variable "entry_point" {
  description = "The name of the function exported by the source code."
  type        = string
}

variable "source_dir" {
  description = "Absolute path to the local directory containing the function source code."
  type        = string
}

variable "trigger_bucket" {
  description = "Name of the GCS bucket whose object finalize events trigger this function."
  type        = string
}

variable "environment_variables" {
  description = "Environment variables to set on the function."
  type        = map(string)
  default     = {}
}

