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

resource "aws_batch_job_queue" "this" {
    name = "${var.job_name}-job-queue"
    state = "ENABLED"
    priority = 1
    compute_environments = [aws_batch_compute_environment.this.arn]
}

locals {
    container_props = jsonencode({
        image = var.job_image
        command = ["python", "/app/extract.py",
                    "--input", "s3://${var.raw_bucket}",
                    "--output", "s3://${var.curated_bucket}"]
        environment = [
            { name = "RAW_BUCKET", value = var.raw_bucket },
            { name = "CURATED_BUCKET", value = var.curated_bucket }
        ]
        executionRoleArn = aws_iam_role.batch_execution_role.arn
        jobRoleArn = aws_iam_role.batch_job_role.arn
        resourceRequirements = [
            { type = "VCPU", value = "1" },
            { type = "MEMORY", value = "2048" }
        ]
        networkConfiguration = {
            assignPublicIp = "DISABLED"
        }
    })
}

data "aws_region" "current" {}

resource "aws_batch_job_definition" "this" {
    name = "${var.job_name}-job-definition"
    type = "container"
    platform_capabilities = ["FARGATE"]
    propagate_tags = true
    container_properties = local.container_props
}