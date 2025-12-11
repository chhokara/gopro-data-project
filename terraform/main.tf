locals {
  required_services = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "artifactregistry.googleapis.com",
    "iamcredentials.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
  ]

  project_id = "gopro-data-project"
  region     = "us-central1"

  raw_bucket_name     = "gopro-raw-data-bucket"
  curated_bucket_name = "gopro-curated-data-bucket"

  artifact_repo = "gopro-artifact-repo"
}

resource "google_project_service" "required_services" {
  for_each = toset(local.required_services)
  project  = local.project_id
  service  = each.key

  disable_dependent_services = true
}

module "raw_bucket" {
  source            = "./modules/gcs-bucket"
  name              = local.raw_bucket_name
  project_id        = local.project_id
  autoclass_enabled = true
  lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 30
      }
    }
  ]
  labels = {
    environment = "dev"
    layer       = "raw"
    project     = "gopro-data"
  }

  notification = {
    topic          = "gopro-data-topic"
    payload_format = "JSON_API_V1"
    event_types    = ["OBJECT_FINALIZE"]
  }

  force_destroy = true

  depends_on = [google_project_service.required_services]
}

module "curated_bucket" {
  source            = "./modules/gcs-bucket"
  name              = local.curated_bucket_name
  project_id        = local.project_id
  autoclass_enabled = true
  lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 90
      }
    }
  ]
  labels = {
    environment = "dev"
    layer       = "curated"
    project     = "gopro-data"
  }

  force_destroy = true

  depends_on = [google_project_service.required_services]
}

module "pubsub" {
  source            = "./modules/pubsub"
  project_id        = local.project_id
  topic_name        = "gopro-data-topic"
  subscription_name = "gopro-data-subscription"

  depends_on = [google_project_service.required_services]
}

module "artifact_registry" {
  source        = "./modules/artifact-registry"
  project_id    = local.project_id
  repository_id = local.artifact_repo
  region        = local.region

  depends_on = [google_project_service.required_services]
}

resource "google_service_account" "airflow_orchestrator" {
  account_id   = "airflow-orchestrator"
  display_name = "Airflow Orchestrator Service Account"
  project      = local.project_id
}

resource "google_project_iam_member" "airflow_gcs" {
  project = local.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.airflow_orchestrator.email}"
}

resource "google_project_iam_member" "airflow_pubsub_sub" {
  project = local.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.airflow_orchestrator.email}"
}

resource "google_project_iam_member" "airflow_pubsub_pub" {
  project = local.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.airflow_orchestrator.email}"
}

resource "google_project_iam_member" "gpmf_job_runner" {
  project = local.project_id
  role    = "roles/run.jobRunner"
  member  = "serviceAccount:${google_service_account.airflow_orchestrator.email}"
}

module "cloud_run_job_service" {
  source             = "./modules/cloud-run-job"
  project_id         = local.project_id
  region             = local.region
  service_account_id = "cloud-run-job-sa"
  job_name           = "gopro-data-processor-job"
  container_image    = "${local.region}-docker.pkg.dev/${local.project_id}/${local.artifact_repo}/gpmf-extractor:v1"
  invoker_member     = "serviceAccount:${google_service_account.airflow_orchestrator.email}"
  curated_bucket     = local.curated_bucket_name
  out_prefix         = "gpmf/"

  depends_on = [google_project_service.required_services]
}