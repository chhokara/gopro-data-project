module "raw_bucket" {
    source = "./modules/s3-bucket"
    bucket_name = var.bucket_name
    force_destroy = var.force_destroy
    common_tags = var.common_tags
}