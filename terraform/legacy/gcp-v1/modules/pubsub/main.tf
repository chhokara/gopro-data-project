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

  dynamic "push_config" {
    for_each = var.push_endpoint != "" ? [1] : []
    content {
      push_endpoint = var.push_endpoint

      oidc_token {
        service_account_email = var.push_service_account_email
        audience              = var.push_audience != "" ? var.push_audience : var.push_endpoint
      }
    }
  }

  labels = var.labels

  lifecycle {
    precondition {
      condition     = var.push_endpoint == "" || var.push_service_account_email != ""
      error_message = "push_service_account_email must be set when push_endpoint is provided."
    }
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
