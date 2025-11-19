locals {
  required_services = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "pubsub.googleapis.com",
    "bigquery.googleapis.com",
    "artifactregistry.googleapis.com",
    "containeranalysis.googleapis.com",
    "run.googleapis.com",
    "iamcredentials.googleapis.com",
  ]

  project_id = "gopro-data-project"
  region     = "us-central1"

  raw_bucket_name     = "gopro-raw-data-bucket"
  curated_bucket_name = "gopro-curated-data-bucket"

  artifact_repo = "gopro-artifact-repo"
  image_name    = "gpmf-extractor"
  image_tag     = "v1"
}

data "google_project" "current" {
  project_id = local.project_id
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
    topic          = module.pubsub.pubsub_topic
    payload_format = "JSON_API_V1"
    event_types    = ["OBJECT_FINALIZE"]
  }

  force_destroy = true

  depends_on = [module.pubsub, google_project_service.required_services]
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
  source                     = "./modules/pubsub"
  project_id                 = local.project_id
  topic_name                 = "gopro-data-topic"
  subscription_name          = "gopro-data-subscription"
  push_endpoint              = google_cloud_run_service.gpmf_extractor.status[0].url
  push_service_account_email = google_service_account.pubsub_invoker.email
  push_audience              = google_cloud_run_service.gpmf_extractor.status[0].url
  labels                     = { trigger = "gcs-object-finalize" }

  depends_on = [
    google_cloud_run_service.gpmf_extractor,
    google_service_account_iam_member.pubsub_token_creator,
    google_project_service.required_services
  ]
}

resource "google_service_account" "cloud_run_sa" {
  account_id   = "gpmf-runner"
  display_name = "Cloud Run runtime for GPMF extraction"
}

resource "google_service_account" "pubsub_invoker" {
  account_id   = "gpmf-run-push"
  display_name = "Identity used by Pub/Sub push to Cloud Run"
}

resource "google_service_account_iam_member" "pubsub_token_creator" {
  service_account_id = google_service_account.pubsub_invoker.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "cloud_run_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/pubsub.subscriber"
  ])
  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

module "artifact_registry" {
  source        = "./modules/artifact-registry"
  project_id    = local.project_id
  repository_id = local.artifact_repo
  region        = local.region
  reader_principals = [
    "serviceAccount:${google_service_account.cloud_run_sa.email}"
  ]

  depends_on = [google_project_service.required_services]
}

resource "google_cloud_run_service" "gpmf_extractor" {
  name     = "gpmf-extractor"
  location = local.region

  template {
    metadata {
      annotations = {
        "run.googleapis.com/ingress"       = "internal-and-cloud-load-balancing"
        "autoscaling.knative.dev/maxScale" = "3"
      }
    }

    spec {
      service_account_name = google_service_account.cloud_run_sa.email

      containers {
        image = "${local.region}-docker.pkg.dev/${local.project_id}/${local.artifact_repo}/${local.image_name}:${local.image_tag}"

        env {
          name  = "RAW_BUCKET"
          value = local.raw_bucket_name
        }

        env {
          name  = "CURATED_BUCKET"
          value = local.curated_bucket_name
        }

        env {
          name  = "REGION"
          value = local.region
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true

  depends_on = [
    module.artifact_registry,
    google_project_service.required_services
  ]
}

resource "google_cloud_run_service_iam_member" "pubsub_invoker" {
  location = google_cloud_run_service.gpmf_extractor.location
  project  = local.project_id
  service  = google_cloud_run_service.gpmf_extractor.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.pubsub_invoker.email}"

  depends_on = [google_cloud_run_service.gpmf_extractor]
}

resource "google_storage_bucket_iam_member" "runner_read_raw" {
  bucket = module.raw_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_run_sa.email}"

  depends_on = [module.raw_bucket]
}

resource "google_storage_bucket_iam_member" "runner_write_curated" {
  bucket = module.curated_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloud_run_sa.email}"

  depends_on = [module.curated_bucket]
}
