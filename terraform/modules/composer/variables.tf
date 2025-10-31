variable "project_id" {
  description = "The ID of the project in which to create the Cloud Composer environment."
  type        = string
}

variable "region" {
  description = "The region in which to create the Cloud Composer environment."
  type        = string
}

variable "environment_name" {
  description = "The name of the Cloud Composer environment."
  type        = string
}

variable "network" {
  description = "The VPC network for the Cloud Composer environment."
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork for the Cloud Composer environment."
  type        = string
}

variable "raw_bucket_name" {
  description = "The name of the raw data GCS bucket."
  type        = string
}

variable "curated_bucket_name" {
  description = "The name of the curated data GCS bucket."
  type        = string
}

# variable bq_datasets {
#   description = "A list of BigQuery dataset IDs to which the Composer service account will be granted access."
#   type        = list(string)
#   default     = []
# }

variable "dags_bucket_name" {
  description = "The name of the GCS bucket to store DAGs."
  type        = string
}

variable "image_version" {
  description = "The version of the Cloud Composer image to use."
  type        = string
  default     = "composer-2.6.4-airflow-2.8.1"
}

variable "scheduler" {
  type = object({
    cpu        = number
    memory_gb  = number
    storage_gb = number
    count      = number
  })
  default = {
    cpu        = 2
    memory_gb  = 4
    storage_gb = 10
    count      = 1
  }
}

variable "web_server" {
  type = object({
    cpu        = number
    memory_gb  = number
    storage_gb = number
  })
  default = {
    cpu        = 2
    memory_gb  = 4
    storage_gb = 10
  }
}

variable "worker" {
  type = object({
    cpu        = number
    memory_gb  = number
    storage_gb = number
    min_count  = number
    max_count  = number
  })
  default = {
    cpu        = 2
    memory_gb  = 8
    storage_gb = 10
    min_count  = 1
    max_count  = 3
  }
}

variable "airflow_env_vars" {
  description = "A map of environment variables to set in the Airflow environment."
  type        = map(string)
  default     = {}
}

variable "airflow_config_overrides" {
  description = "A map of Airflow configuration overrides."
  type        = map(string)
  default     = {}
}
