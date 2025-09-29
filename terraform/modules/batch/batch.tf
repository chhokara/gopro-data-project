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