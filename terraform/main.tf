### new comment
locals {
  required_services = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "iamcredentials.googleapis.com",
    "iam.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "eventarc.googleapis.com",
    "cloudbuild.googleapis.com",
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

resource "google_storage_bucket_iam_member" "airflow_raw" {
  bucket = module.buckets["raw"].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.airflow_orchestrator.email}"
}

resource "google_storage_bucket_iam_member" "airflow_curated" {
  bucket = module.buckets["curated"].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.airflow_orchestrator.email}"
}

# module "gopro_trigger" {
#   source = "./modules/cloud-run-function"

#   project_id     = var.gcp_project_id
#   region         = var.gcp_region
#   name           = "gopro-pipeline-trigger"
#   runtime        = "python312"
#   entry_point    = "trigger_pipeline"
#   source_dir     = "${path.module}/../cloud_run_function"
#   trigger_bucket = module.buckets["raw"].name

#   environment_variables = {
#     AIRFLOW_DAG_ID   = "gopro_pipeline"
#     AIRFLOW_URL      = var.airflow_url
#     AIRFLOW_USERNAME = var.airflow_username
#     AIRFLOW_PASSWORD = var.airflow_password
#   }

#   depends_on = [google_project_service.required_services]
# }
