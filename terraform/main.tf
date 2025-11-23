locals {
  required_services = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "artifactregistry.googleapis.com",
    "iamcredentials.googleapis.com",
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