resource "aws_s3_bucket" "gopro_data" {
    bucket = var.bucket_name
    force_destroy = var.force_destroy

    tags = var.common_tags
}

resource "aws_s3_bucket_ownership_controls" "gopro_data_ownership" {
    bucket = aws_s3_bucket.gopro_data.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_public_access_block" "gopro_data_public_access" {
    bucket = aws_s3_bucket.gopro_data.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "gopro_data_encryption" {
    bucket = aws_s3_bucket.gopro_data.id
    
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}