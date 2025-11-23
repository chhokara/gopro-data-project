data "google_project" "current" {
  project_id = var.project_id
}

locals {
  gcs_publisher_sa = "serviceAccount:service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_pubsub_topic" "this" {
  project = var.project_id
  name    = var.topic_name
}

resource "google_pubsub_subscription" "this" {
  project = var.project_id
  name    = var.subscription_name
  topic   = google_pubsub_topic.this.name

  ack_deadline_seconds       = var.ack_deadline_seconds
  message_retention_duration = var.message_retention_duration
  retain_acked_messages      = var.retain_acked_messages

  expiration_policy {
    ttl = ""
  }
  
  depends_on = [google_pubsub_topic.this]
}

resource "google_pubsub_topic_iam_member" "this" {
  project = var.project_id
  topic   = google_pubsub_topic.this.name
  role    = "roles/pubsub.publisher"
  member  = local.gcs_publisher_sa

  depends_on = [google_pubsub_topic.this]
}
