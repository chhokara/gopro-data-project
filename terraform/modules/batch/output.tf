output "batch_job_role_arn" {
    value = aws_iam_role.batch_job_role.arn
    description = "ARN of the IAM role for the Batch job"
}

output "batch_execution_role_arn" {
    value = aws_iam_role.batch_execution_role.arn
    description = "ARN of the IAM role for Batch job execution"
}