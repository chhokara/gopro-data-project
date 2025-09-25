variable "subnet_ids" {
  description = "Private subnet IDs for the Batch compute environment"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the Batch compute environment"
  type        = string
}

variable "job_image" {
  description = "Docker image for the Batch job"
  type        = string
}

variable "job_name" {
  description = "Logical name for the Batch job"
  type        = string
  default     = "gopro-telemetry-extract"
}

variable "raw_bucket" {
  description = "S3 bucket for raw data"
  type        = string
}

variable "curated_bucket" {
  description = "S3 bucket for curated data"
  type        = string
}