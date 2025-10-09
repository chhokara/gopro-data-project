variable "name" {
    description = "The name of the VPC"
    type        = string
}

variable "cidr" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "az_count" {
    description = "The number of availability zones to use"
    type        = number
    default     = 2
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets (length must equal az_count)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
    description = "List of CIDR blocks for private subnets"
    type        = list(string)
    default     = ["10.0.100.0/24", "10.0.101.0/24"
}

variable "enable_nat_gateway" {
    description = "Whether to enable NAT Gateway"
    type        = bool
    default     = true
}

variable "tags" {
    description = "A map of tags to assign to the resources"
    type        = map(string)
    default     = {}
}