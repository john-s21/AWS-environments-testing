// ---------------------------------------------------------------------------
// Dev & Deploy Auth Vars
variable "aws_credential_file" {
  type    = string
  default = "~/.aws/credentials"
}

variable "aws_profile" {
  type    = string
  default = null
}

// ---------------------------------------------------------------------------

// Project Vars
variable "project_prefix" {
  type    = string
  default = "eyproject"
}

variable "environment" {
  type        = string
  description = "Environment label (i.e. dev, sit, uat, prd)"
  validation {
    condition     = contains(["dev", "sit", "uat", "prd"], var.environment)
    error_message = "Invalid environment variable provided."
  }
}

variable "aws_tags_user" {
  type        = map(any)
  description = "Mappings for the resource"
}

locals {
  aws_tags_global = merge(
    var.aws_tags_user,
    {
      Application          = "client"
      Consumer             = "email@abc.com"
      Costcenter           = "1111111"
      Division             = "ABC"
      NetworkActivityCodes = "0000000"
      DataClassification   = "Non-Sensitive"
    }
  )
}

// ---------------------------------------------------------------------------
// AWS Account Vars
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_account_number" {
  type = string
}

// ---------------------------------------------------------------------------
