variable "role_config_file_path" {
    type = string
    description = "File path for the json template file to be formatted"
}

variable "role_template_variable_map" {
  type = map
  description = "Map for all input variables in the policy template"
  validation {
    condition     = contains(keys(var.role_template_variable_map), "project_prefix") && contains(keys(var.role_template_variable_map), "environment") && contains(["dev", "sit", "uat", "prd"], lookup(var.role_template_variable_map, "environment"))
    error_message = "Missing or invalid environment variablr, or missing project prefix."
  }
}

# Module dependency hack
variable "module_depends_on" {
  type = any
}
