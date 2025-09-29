module "raw_bucket" {
  source = "./modules/s3"
}

module "eventbridge" {
  source = "./modules/eventbridge"
}

# module "vpc" {
#     source = "../vpc"

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