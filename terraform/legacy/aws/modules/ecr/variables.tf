variable "name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "push_principals" {
  description = "ARNs allowed to push to the repository"
  type        = list(string)
  default     = []
}

variable "pull_principals" {
  description = "ARNs allowed to pull from the repository"
  type        = list(string)
  default     = []
}

variable "immutable_tags" {
  description = "Whether to make tags immutable"
  type        = bool
  default     = true
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "untagged_expire_days" {
  description = "Expire untagged images after N days."
  type        = number
  default     = 7
}

variable "keep_last_tagged" {
  description = "Keep the last N tagged images."
  type        = number
  default     = 20
}

variable "tags" {
  description = "A map of tags to assign to the repository"
  type        = map(string)
  default     = {}
}