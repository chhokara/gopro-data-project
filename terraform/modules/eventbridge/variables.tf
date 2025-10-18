variable "batch_job_role_arn" {
  description = "The ARN of the Batch Job Role"
  type        = string
}

variable "batch_execution_role_arn" {
  description = "The ARN of the Batch Execution Role"
  type        = string
}

variable "source_bucket_name" {
  description = "The name of the S3 bucket to monitor for object creation events"
  type        = string
}

variable "batch_job_queue_arn" {
  description = "The ARN of the Batch Job Queue"
  type        = string
}

variable "batch_job_definition_arn" {
  description = "The ARN of the Batch Job Definition"
  type        = string
}

variable "batch_job_name" {
  description = "The name of the Batch Job"
  type        = string
}

variable "batch_array_size" {
  description = "The size of the array job"
  type        = number
  default     = 1
}

variable "batch_job_attempts" {
  description = "The number of attempts for the job"
  type        = number
  default     = 1
}