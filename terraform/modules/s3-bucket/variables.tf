variable bucket_name {
    description = "Name of the S3 bucket"
    type        = string
    default     = "gopro-data-bucket"
}

variable force_destroy {
    description = "Allow destroy of bucket with objects"
    type        = bool
    default     = true
}

variable common_tags {
    description = "Common tags for AWS resource"
    type        = map(string)
    default     = {
        project = "gopro-data-project"
        managed_by = "terraform"
    }
}