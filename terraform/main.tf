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
}