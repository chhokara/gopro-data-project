resource "google_bigquery_dataset" "this" {
  dataset_id                 = var.dataset_id
  project                    = var.project_id
  location                   = var.location
  description                = var.description
  delete_contents_on_destroy = var.delete_contents_on_destroy

  labels = merge(
    {
      managed = "terraform"
      module  = "bigquery"
    },
    var.labels
  )
}
