resource "aws_s3_bucket" "gopro_raw_data" {
    bucket = "gopro-raw-data-bucket"
    force_destroy = var.s3_force_destroy

    tags = var.common_tags
}

resource "aws_s3_bucket_ownership_controls" "gopro_raw_data_ownership" {
    bucket = aws_s3_bucket.gopro_raw_data.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_public_access_block" "gopro_raw_data_public_access" {
    bucket = aws_s3_bucket.gopro_raw_data.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "gopro_raw_data_encryption" {
    bucket = aws_s3_bucket.gopro_raw_data.id
    
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}