output "dataset_id" {
  description = "The ID of the BigQuery dataset."
  value       = google_bigquery_dataset.this.dataset_id
}

output "self_link" {
  description = "The self link of the BigQuery dataset."
  value       = google_bigquery_dataset.this.self_link
}
