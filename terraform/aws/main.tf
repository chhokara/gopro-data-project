# module "raw_bucket" {
#   source = "./modules/s3"
#   bucket_name = "gopro-raw-bucket"
# }

# module "curated_bucket" {
#   source = "./modules/s3"
#   bucket_name = "gopro-curated-bucket"
# }

# module "eventbridge" {
#   source = "./modules/eventbridge"

#   batch_job_role_arn       = module.batch.batch_job_role_arn
#   batch_execution_role_arn = module.batch.batch_execution_role_arn
#   source_bucket_name       = module.raw_bucket.bucket_name
#   batch_job_queue_arn      = module.batch.batch_job_queue_arn
#   batch_job_definition_arn = module.batch.batch_job_definition_arn
#   batch_job_name           = module.batch.batch_job_name
#   batch_array_size         = 1
#   batch_job_attempts       = 1
# }

# module "vpc" {
#     source = "./modules/vpc"

#     name = "gopro-vpc"
#     cidr = "10.20.0.0/16"
#     az_count = 2

#     public_subnet_cidrs = ["10.20.0.0/24", "10.20.1.0/24"]
#     private_subnet_cidrs = ["10.20.100.0/24", "10.20.101.0/24"]

#     enable_nat_gateway = true

#     tags = {
#         project = "gopro"
#         managed = "terraform"
#     }
# }

# module "batch" {
#   source = "./modules/batch"

#   vpc_id = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnet_ids
#   job_image = ""
#   job_name = "gopro-telemetry-extract"
#   raw_bucket = module.raw_bucket.bucket_name
#   curated_bucket = module.curated_bucket.bucket_name
# }