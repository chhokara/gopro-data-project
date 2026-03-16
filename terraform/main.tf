### testing
locals {
  required_services = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "iamcredentials.googleapis.com",
    "iam.googleapis.com",
  ]

  buckets = {
    raw = {
      name          = "gopro-raw-data-bucket"
      lifecycle_age = 30
      layer         = "raw"
    }
    curated = {
      name          = "gopro-curated-data-bucket"
      lifecycle_age = 90
      layer         = "curated"
    }
  }
}

resource "google_project_service" "required_services" {
  for_each = toset(local.required_services)
  project  = var.gcp_project_id
  service  = each.key

  disable_dependent_services = true
}

module "buckets" {
  source   = "./modules/gcs-bucket"
  for_each = local.buckets

  name              = each.value.name
  project_id        = var.gcp_project_id
  autoclass_enabled = true
  lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = each.value.lifecycle_age
      }
    }
  ]
  labels = {
    environment = "dev"
    layer       = each.value.layer
    project     = "gopro-data"
  }

  force_destroy = true

  depends_on = [google_project_service.required_services]
}

resource "google_service_account" "airflow_orchestrator" {
  account_id   = "airflow-orchestrator"
  display_name = "Airflow Orchestrator Service Account"
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "airflow_gcs" {
  project = var.gcp_project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.airflow_orchestrator.email}"
}
