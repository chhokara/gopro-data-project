variable "project_id" {
  description = "The ID of the project in which the dataset will be created."
  type        = string
}

variable "dataset_id" {
  description = "The ID of the BigQuery dataset."
  type        = string
}

variable "location" {
  description = "The location where the dataset will be created."
  type        = string
  default     = "US"
}

variable "description" {
  description = "A description of the dataset."
  type        = string
  default     = ""
}

variable "delete_contents_on_destroy" {
  description = "Whether to delete all tables in the dataset when the dataset is destroyed."
  type        = bool
  default     = false
}

variable "labels" {
  description = "A map of labels to apply to the dataset."
  type        = map(string)
  default     = {}
}
