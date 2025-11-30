resource "google_service_account" "gpmf_job_sa" {
  account_id   = var.service_account_id
  display_name = "Service Account for GPMF Cloud Run Job"
}

resource "google_project_iam_member" "gpmf_job_storage_access" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.gpmf_job_sa.email}"
}

resource "google_project_iam_member" "gpmf_job_bigquery_access" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.gpmf_job_sa.email}"
}

resource "google_cloud_run_v2_job" "gpmf_job" {
  name     = var.job_name
  location = var.region

  template {
    template {
      containers {
        image = var.container_image

        env {
          name  = "RAW_BUCKET"
          value = ""
        }

        env {
          name  = "CURATED_BUCKET"
          value = var.curated_bucket
        }

        env {
          name  = "OBJECT_NAME"
          value = ""
        }

        env {
          name  = "OUT_PREFIX"
          value = var.out_prefix
        }
      }

      service_account_name = google_service_account.gpmf_job_sa.email
      max_retries          = 1
      timeout              = "900s"
    }
  }
}

resource "google_cloud_run_v2_job_iam_member" "gpmf_job_invoker" {
  location = var.region
  project  = var.project_id
  name     = google_cloud_run_v2_job.gpmf_job.name
  role     = "roles/run.invoker"
  member   = var.invoker_member
}
