variable "project_prefix" { type = string }
variable "environment" { type = string }
variable "role_name" { type = string }
variable "assume_role_policy" { type = string }

variable "permissions_boundary_arn" {
  description = "Optional ARN for permission boundary"
  type        = string
  default     = ""
}

variable "custom_policy_arns" {
  description = "List of custom policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach"
  type        = list(string)
  default     = []
}