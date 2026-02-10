variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "ap-south-1"
}


variable "aws_account_number" {
  description = "902193012760"
  type        = string
}

variable "project_prefix" {
  description = "multienvironment"
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, sit, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "sit", "prod"], var.environment)
    error_message = "Environment must be one of: dev, sit, prod."
  }
}



