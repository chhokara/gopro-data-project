output "name" {
  description = "The name of the GCS bucket"
  value       = google_storage_bucket.this.name
}

output "url" {
  description = "The URL of the GCS bucket"
  value       = google_storage_bucket.this.url
}

output "self_link" {
  description = "The self link of the GCS bucket"
  value       = google_storage_bucket.this.self_link
}

output "location" {
  description = "The location of the GCS bucket"
  value       = google_storage_bucket.this.location
}

output "storage_class" {
  description = "The storage class of the GCS bucket"
  value       = google_storage_bucket.this.storage_class
}
