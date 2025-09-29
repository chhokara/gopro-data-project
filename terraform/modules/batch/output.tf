output "batch_job_role_arn" {
    value = aws_iam_role.batch_job_role.arn
    description = "ARN of the IAM role for the Batch job"
}

output "batch_execution_role_arn" {
    value = aws_iam_role.batch_execution_role.arn
    description = "ARN of the IAM role for Batch job execution"
}

output "batch_job_queue_arn" {
    value = aws_batch_job_queue.this.arn
    description = "ARN of the Batch job queue"
}

output "batch_job_definition_arn" {
    value = aws_batch_job_definition.this.arn
    description = "ARN of the Batch job definition"
}