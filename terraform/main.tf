module "raw_bucket" {
  source = "./modules/s3-bucket"
}

module "eventbridge" {
  source = "./modules/eventbridge"
}