variable "vpc_cidr" {
    description = "CIDR block of the vpc"
    default     = "10.0.0.0/16"
}

variable "environment" {
    description = "Deployment Environment"
    default     = "dev"
}