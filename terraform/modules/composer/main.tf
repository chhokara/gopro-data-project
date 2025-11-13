data "google_project" "current" {}

resource "google_project_iam_member" "composer_service_agent_ext" {
  project = var.project_id
  role    = "roles/composer.ServiceAgentV2Ext"
  member  = "serviceAccount:service-${data.google_project.current.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}

resource "google_service_account" "composer_sa" {
  account_id   = "${var.environment_name}-composer"
  display_name = "Composer Service Account for ${var.environment_name}"
}

resource "google_storage_bucket_iam_member" "sa_read_raw" {
  bucket = var.raw_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.composer_sa.email}"
}

resource "google_storage_bucket_iam_member" "sa_write_curated" {
  bucket = var.curated_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.composer_sa.email}"
}

resource "google_storage_bucket_iam_member" "sa_read_dags" {
  bucket = var.dags_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.composer_sa.email}"
}

# resource "google_bigquery_dataset_iam_member" "bq_dataset_access" {
#   for_each = toset(var.bq_datasets)
#   dataset_id = each.value
#   role       = "roles/bigquery.dataEditor"
#   member     = "serviceAccount:${google_service_account.composer_sa.email}"
# }

resource "google_project_iam_member" "composer_general_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/compute.viewer",
    "roles/pubsub.subscriber",
    "roles/pubsub.publisher",
    "roles/composer.worker"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

resource "google_composer_environment" "this" {
  name   = "${var.environment_name}-composer"
  region = var.region

  config {
    software_config {
      image_version            = var.image_version
      airflow_config_overrides = var.airflow_config_overrides
      env_variables = merge({
        RAW_BUCKET     = var.raw_bucket_name
        CURATED_BUCKET = var.curated_bucket_name
      }, var.airflow_env_vars)
      pypi_packages = {
        "gcsfs"                                    = ""
        "google-cloud-bigquery"                    = ""
        "google-cloud-storage"                     = ""
        "google-cloud-pubsub"                      = ""
        "apache-airflow-providers-cncf-kubernetes" = ""
        "kubernetes"                               = ""
      }
    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"

    workloads_config {
      scheduler {
        cpu        = var.scheduler.cpu
        memory_gb  = var.scheduler.memory_gb
        storage_gb = var.scheduler.storage_gb
        count      = var.scheduler.count
      }
      web_server {
        cpu        = var.web_server.cpu
        memory_gb  = var.web_server.memory_gb
        storage_gb = var.web_server.storage_gb
      }
      worker {
        cpu        = var.worker.cpu
        memory_gb  = var.worker.memory_gb
        storage_gb = var.worker.storage_gb
        min_count  = var.worker.min_count
        max_count  = var.worker.max_count
      }
    }

    node_config {
      network         = var.network
      subnetwork      = var.subnetwork
      service_account = google_service_account.composer_sa.email
    }
  }

  storage_config {
    bucket = var.dags_bucket_name
  }

  depends_on = [
    google_storage_bucket_iam_member.sa_read_raw,
    google_storage_bucket_iam_member.sa_write_curated,
    google_storage_bucket_iam_member.sa_read_dags,
    google_project_iam_member.composer_general_roles,
    google_project_iam_member.composer_service_agent_ext
  ]
}

