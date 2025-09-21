output "bucket_arn" {
  value       = aws_s3_bucket.gopro_data.arn
  description = "The ARN of the S3 bucket"
}

output "bucket_id" {
  value       = aws_s3_bucket.gopro_data.id
  description = "The ID of the S3 bucket"
}

output "bucket_name" {
  value       = aws_s3_bucket.gopro_data.bucket
  description = "The name of the S3 bucket"
}