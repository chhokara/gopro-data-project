output "function_uri" {
  description = "The URI of the deployed Cloud Run Function."
  value       = google_cloudfunctions2_function.this.service_config[0].uri
}

output "service_account_email" {
  description = "The email of the service account attached to the function."
  value       = google_service_account.this.email
}

