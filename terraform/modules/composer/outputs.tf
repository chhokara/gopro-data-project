output "airflow_uri" {
  value = google_composer_environment.this.config.airflow_uri
}

output "composer_sa_email" {
  value = google_service_account.composer_sa.email
}

output "dags_bucket_name" {
  value = google_storage_bucket.dags.name
}