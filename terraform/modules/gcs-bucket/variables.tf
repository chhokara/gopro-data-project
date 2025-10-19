variable "project_id" {
  description = "The ID of the project in which the bucket will be created."
  type        = string
}

variable "location" {
  description = "The location where the bucket will be created."
  type        = string
  default     = "US"
}

variable "name" {
  description = "The name of the GCS bucket."
  type        = string
}

variable "unform_bucket_level_access" {
  description = "Whether to enable uniform bucket-level access."
  type        = bool
  default     = true
}

variable "public_access_prevention" {
  description = "Whether to enable public access prevention."
  type        = string
  default     = "enforced"
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket."
  type        = bool
  default     = false
}

variable "autoclass_enabled" {
  description = "Whether to enable Autoclass on the bucket."
  type        = bool
  default     = false
}

variable "autoclass_terminal_storage_class" {
  description = "The terminal storage class for Autoclass."
  type        = string
  default     = "ARCHIVE"
}

variable "storage_class" {
  description = "The storage class of the bucket."
  type        = string
  default     = "STANDARD"
}

variable "versioning_enabled" {
  description = "Whether to enable versioning on the bucket."
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "A list of lifecycle rules to apply to the bucket."
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                   = optional(number)
      created_before        = optional(string)
      with_state            = optional(string)
      num_newer_versions    = optional(number)
      matches_storage_class = optional(list(string))
    })
  }))
  default = []
}

variable "labels" {
  description = "A map of labels to apply to the bucket."
  type        = map(string)
  default     = {}
}

variable "iam_members" {
  description = "A list of IAM members to bind to the bucket."
  type = list(object({
    role   = string
    member = string
  }))
  default = []
}

variable "notification" {
  description = "Optional Pub/Sub notification config"
  type = object({
    topic              = string
    payload_format     = optional(string)
    event_types        = optional(list(string))
    object_name_prefix = optional(string)
  })
  default = null
}
