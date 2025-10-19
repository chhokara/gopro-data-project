resource "aws_cloudwatch_event_rule" "s3_object_created" {
  name        = "gopro-s3-object-created"
  description = "Trigger batch job on S3 object creation"
  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [var.source_bucket_name]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "eventbridge_to_batch" {
  rule      = aws_cloudwatch_event_rule.s3_object_created.name
  target_id = "batch-submit"
  arn       = var.batch_job_queue_arn
  role_arn  = aws_iam_role.eventbridge_to_batch.arn

  batch_target {
    job_definition_arn = var.batch_job_definition_arn
    job_name           = var.batch_job_name
    array_size         = var.batch_array_size
    job_attempts       = var.batch_job_attempts
  }
}