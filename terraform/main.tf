locals {
  required_services = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "pubsub.googleapis.com",
    "bigquery.googleapis.com",
    "composer.googleapis.com",
    "artifactregistry.googleapis.com",
    "containeranalysis.googleapis.com",
  ]
  project_id = "gopro-data-project"
  region     = "us-central1"
}

resource "google_project_service" "required_services" {
  for_each = toset(local.required_services)
  project  = local.project_id
  service  = each.key

  disable_dependent_services = true
}

module "raw_bucket" {
  source            = "./modules/gcs-bucket"
  name              = "gopro-raw-data-bucket"
  project_id        = "gopro-data-project"
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
  name              = "gopro-curated-data-bucket"
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

module "dags_bucket" {
  source            = "./modules/gcs-bucket"
  name              = "gopro-composer-dags-bucket"
  project_id        = local.project_id
  autoclass_enabled = false
  labels = {
    environment = "dev"
    project     = "gopro-data"
    purpose     = "composer-dags"
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

module "composer" {
  source           = "./modules/composer"
  environment_name = "gopro-data-composer"
  project_id       = local.project_id
  region           = local.region

  network    = "default"
  subnetwork = "default"

  image_version = "composer-2.14.4-airflow-2.10.5"
  airflow_env_vars = {
    REGION                                             = local.region
    APP_PROJECT_ID                                     = local.project_id
    PUBSUB_TOPIC                                       = module.pubsub.pubsub_topic
    PUBSUB_SUBSCRIPTION                                = module.pubsub.pubsub_subscription
  }

  airflow_config_overrides = {
    "webserver.show_trigger_form_if_no_params" = "True"
  }

  raw_bucket_name     = module.raw_bucket.name
  curated_bucket_name = module.curated_bucket.name
  dags_bucket_name    = module.dags_bucket.name

  depends_on = [module.raw_bucket, module.curated_bucket, module.dags_bucket, module.pubsub, google_project_service.required_services]
}

resource "google_pubsub_subscription_iam_member" "this" {
  project      = local.project_id
  subscription = module.pubsub.pubsub_subscription
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${module.composer.composer_sa_email}"

  depends_on = [module.pubsub, module.composer, google_project_service.required_services]
}

module "artifact_registry" {
  source            = "./modules/artifact-registry"
  project_id        = local.project_id
  repository_id     = "gopro-artifact-repo"
  region            = local.region
  composer_sa_email = module.composer.composer_sa_email

  depends_on = [module.composer, google_project_service.required_services]
}