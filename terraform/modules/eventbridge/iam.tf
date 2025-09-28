data "aws_iam_policy_document" "events_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eventbridge_to_batch" {
  name               = "eventbridge-to-batch-role"
  assume_role_policy = data.aws_iam_policy_document.events_assume_role.json
}

# data "aws_iam_policy_document" "eventbridge_to_batch_policy" {
#     statement {
#         sid = "AllowBatchSubmitJob"
#         actions = ["batch:SubmitJob"]
#         resources = ["*"]
#     }

#     statement {
#         sid = "AllowPassRolesForBatch"
#         actions = ["iam:PassRole"]
#         resources = [
#             module.batch.batch_job_role_arn,
#             module.batch.batch_execution_role_arn
#         ]
#     }
# }

# resource "aws_iam_role_policy" "eventbridge_to_batch_attach" {
#     role = aws_iam_role.eventbridge_to_batch.name
#     policy = data.aws_iam_policy_document.eventbridge_to_batch_policy.json
# }