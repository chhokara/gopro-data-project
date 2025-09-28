module "raw_bucket" {
  source = "./modules/s3"
}

module "eventbridge" {
  source = "./modules/eventbridge"
}