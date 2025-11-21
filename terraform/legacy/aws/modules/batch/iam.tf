data "aws_iam_policy_document" "execution_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "batch_execution_role" {
  name               = "batch-execution-role"
  assume_role_policy = data.aws_iam_policy_document.execution_assume.json
}

resource "aws_iam_role_policy_attachment" "batch_execution_attach" {
  role       = aws_iam_role.batch_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "job_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "batch_job_role" {
  name               = "batch-job-role"
  assume_role_policy = data.aws_iam_policy_document.job_assume.json
}

data "aws_iam_policy_document" "job_access" {
  statement {
    sid = "ReadRaw"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.raw_bucket}",
      "arn:aws:s3:::${var.raw_bucket}/*"
    ]
  }

  statement {
    sid = "WriteCurated"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      "arn:aws:s3:::${var.curated_bucket}",
      "arn:aws:s3:::${var.curated_bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "job_access" {
  name   = "batch-job-access-s3"
  policy = data.aws_iam_policy_document.job_access.json
}

resource "aws_iam_role_policy_attachment" "job_access_attach" {
  role       = aws_iam_role.batch_job_role.name
  policy_arn = aws_iam_policy.job_access.arn
}
