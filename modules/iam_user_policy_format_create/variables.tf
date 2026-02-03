variable "user_policy_file_path" {
    type = string
    description = "File path for the json template file to be formatted"
}

variable "policy_template_variable_map" {
  type = map
  description = "Map for all input variables in the policy template"
  validation {
    condition     = contains(keys(var.policy_template_variable_map), "project_prefix") && contains(keys(var.policy_template_variable_map), "environment") && contains(["dev", "sit", "uat", "prd"], lookup(var.policy_template_variable_map, "environment"))
    error_message = "Missing or invalid environment variablr, or missing project prefix."
  }
}
