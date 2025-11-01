locals {
  repo_path = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
}

resource "google_artifact_registry_repository" "this" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  description   = "Docker images for GoPro ETL"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}

resource "google_artifact_registry_repository_iam_member" "this" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.this.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.composer_sa_email}"
}