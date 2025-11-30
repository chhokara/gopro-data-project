output "gpmf_job_name" {
  description = "The name of the Cloud Run Job."
  value       = google_cloud_run_job.gpmf_job.name
}

output "gpmf_job_location" {
  description = "The location of the Cloud Run Job."
  value       = google_cloud_run_job.gpmf_job.location
}