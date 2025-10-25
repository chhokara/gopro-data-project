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
