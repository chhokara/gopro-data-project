data "google_project" "this" {
  project_id = var.project_id
}

resource "google_service_account" "this" {
  account_id   = "${var.name}-sa"
  display_name = "${var.name} Service Account"
  project      = var.project_id
}

# Dedicated bucket to store the zipped function source code
resource "google_storage_bucket" "source" {
  name                        = "${var.project_id}-${var.name}-source"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true

}

# Zip the local source directory
data "archive_file" "source" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/tmp_${var.name}_source.zip"
}

# Upload the zip — content hash in filename forces a new object on every code change
resource "google_storage_bucket_object" "source" {
  name   = "source_${data.archive_file.source.output_md5}.zip"
  bucket = google_storage_bucket.source.name
  source = data.archive_file.source.output_path
}

resource "google_cloudfunctions2_function" "this" {
  name     = var.name
  location = var.region
  project  = var.project_id

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point

    source {
      storage_source {
        bucket = google_storage_bucket.source.name
        object = google_storage_bucket_object.source.name
      }
    }
  }

  service_config {
    service_account_email = google_service_account.this.email
    environment_variables = var.environment_variables
  }

  event_trigger {
    trigger_region        = var.region
    event_type            = "google.cloud.storage.object.v1.finalized"
    service_account_email = google_service_account.this.email

    event_filters {
      attribute = "bucket"
      value     = var.trigger_bucket
    }
  }
}

# Allow the function's SA to invoke the backing Cloud Run service
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloudfunctions2_function.this.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.this.email}"
}

# GCS service agent must be able to publish Eventarc events via Pub/Sub
resource "google_project_iam_member" "gcs_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.this.number}@gs-project-accounts.iam.gserviceaccount.com"
}
