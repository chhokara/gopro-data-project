module "vpc" {
    source = "../vpc"

    name = "gopro-vpc"
    cidr = "10.20.0.0/16"
    az_count = 2

    public_subnet_cidrs = ["10.20.0.0/24", "10.20.1.0/24"]
    private_subnet_cidrs = ["10.20.100.0/24", "10.20.101.0/24"]

    enable_nat_gateway = true

    tags = {
        project = "gopro"
        managed = "terraform"
    }
}

resource "aws_security_group" "batch" {
    name = "gopro-batch-sg"
    description = "Security group for AWS Batch"
    vpc_id = module.vpc.vpc_id

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        project = "gopro"
        managed = "terraform"
    }
}

resource "aws_batch_compute_environment" "this" {
    compute_environment_name = "${var.job_name}-compute-environment"
    type                    = "MANAGED"

    compute_resources {
        type = "FARGATE"
        max_vcpus = 64
        subnets = module.vpc.private_subnet_ids
        security_group_ids = [aws_security_group.batch.id]
    }
}