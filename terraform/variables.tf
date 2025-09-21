variable tfc_api_token {
    description = "Terraform Cloud API token"
    type        = string
    sensitive   = true
}

variable tfc_email {
    description = "Terraform Cloud Email"
    type        = string
}

variable github_oauth_token_id {
    description = "GitHub OAuth Token"
    type        = string
    sensitive   = true
}

variable aws_region {
    description = "AWS Region"
    type        = string
    default     = "us-west-2"
}

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