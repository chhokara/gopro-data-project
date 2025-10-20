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
  notification = {
    topic = "gopro-data-topic"
    payload_format = "JSON_API_V1"
    event_types = ["OBJECT_FINALIZE"]
    object_name_prefix = "raw/"
  }
}

module "pubsub" {
  source                = "./modules/pubsub"
  project_id            = "gopro-data-project"
  topic_name            = "gopro-data-topic"
  subscription_name     = "gopro-data-subscription"
  # subscriber_service_account = "service-account-email"
}