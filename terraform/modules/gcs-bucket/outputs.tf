output "name" {
  description = "The name of the GCS bucket"
  value       = google_storage_bucket.bucket.name
}

output "url" {
  description = "The URL of the GCS bucket"
  value       = google_storage_bucket.bucket.url
}

output "self_link" {
  description = "The self link of the GCS bucket"
  value       = google_storage_bucket.bucket.self_link
}

output "location" {
  description = "The location of the GCS bucket"
  value       = google_storage_bucket.bucket.location
}

output "storage_class" {
  description = "The storage class of the GCS bucket"
  value       = google_storage_bucket.bucket.storage_class
}
