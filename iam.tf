locals {
  iam_policy_dir               = "${path.module}/iam_policy"
  iam_policy_template_files    = fileset("${local.iam_policy_dir}", "*.json.tmpl")
  iam_policy_template_filepath = { for f in local.iam_policy_template_files : f => "${local.iam_policy_dir}/${f}" }

  iam_role_dir               = "${path.module}/iam_roles"
  iam_role_template_files    = fileset("${local.iam_role_dir}", "*.json.tmpl")
  iam_role_template_filepath = { for f in local.iam_role_template_files : f => "${local.iam_role_dir}/${f}" }

  iam_user_policy_dir               = "${path.module}/iam_user_policy"
  iam_user_policy_template_files    = fileset("${local.iam_user_policy_dir}", "*.json.tmpl")
  iam_user_policy_template_filepath = { for f in local.iam_user_policy_template_files : f => "${local.iam_user_policy_dir}/${f}" }
}

module "iam_policy_format_create" {
  source           = "./modules/iam_policy_format_create"
  for_each         = local.iam_policy_template_filepath
  policy_file_path = each.value

  policy_template_variable_map = {
    project_prefix     = var.project_prefix 
    environment        = var.environment    
    aws_region         = var.aws_region
    aws_account_number = var.aws_account_number
  }
}

module "iam_role_create" {
  source                = "./modules/iam_role_create"
  for_each              = local.iam_role_template_filepath
  role_config_file_path = each.value

  role_template_variable_map = {
    project_prefix     = var.project_prefix 
    environment        = var.environment   
    aws_region         = var.aws_region
    aws_account_number = var.aws_account_number
  }
  module_depends_on = values(module.iam_policy_format_create)[*].aws_iam_policy_output
}

module "iam_user_policy_format_create" {
  source                = "./modules/iam_user_policy_format_create"
  for_each              = local.iam_user_policy_template_filepath
  user_policy_file_path = each.value

  policy_template_variable_map = {
    project_prefix     = var.project_prefix 
    environment        = var.environment   
    aws_region         = var.aws_region
    aws_account_number = var.aws_account_number
  }
}
