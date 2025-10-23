resource "google_project_service" "pubsub" {
  project = var.project_id
  service = "pubsub.googleapis.com"
}

data "google_project" "current" {
  project_id = var.project_id
}

resource "google_pubsub_topic" "this" {
  project    = var.project_id
  name       = var.topic_name
  depends_on = [google_project_service.pubsub]
}

resource "google_pubsub_subscription" "this" {
  project = var.project_id
  name    = var.subscription_name
  topic   = google_pubsub_topic.this.name

  ack_deadline_seconds       = 30
  message_retention_duration = "1200s"
  retain_acked_messages      = false

  expiration_policy {
    ttl = ""
  }

  depends_on = [google_project_service.pubsub]
}

resource "google_pubsub_topic_iam_member" "this" {
  project = var.project_id
  topic   = google_pubsub_topic.this.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# resource "google_pubsub_subscription_iam_member" "this" {
#     project = var.project_id
#     subscription = google_pubsub_subscription.this.name
#     role = "roles/pubsub.subscriber"
#     member = "serviceAccount:${var.subscriber_service_account}"
# }