variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "topic_name" {
  description = "The name of the Pub/Sub topic."
  type        = string
}

variable "subscription_name" {
  description = "The name of the Pub/Sub subscription."
  type        = string
}

variable "ack_deadline_seconds" {
  description = "Ack deadline for the subscription."
  type        = number
  default     = 30
}

variable "message_retention_duration" {
  description = "How long to retain unacknowledged messages."
  type        = string
  default     = "1200s"
}

variable "retain_acked_messages" {
  description = "Whether to retain acknowledged messages."
  type        = bool
  default     = false
}