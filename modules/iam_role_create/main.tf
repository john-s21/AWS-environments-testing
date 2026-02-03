locals {
  environment = lookup(var.role_template_variable_map, "environment")
  project_prefix = lookup(var.role_template_variable_map, "project_prefix")

  json_config = jsondecode(file("${var.role_config_file_path}"))
  assume_role_policy = local.json_config.assume_role_policy
  attach_policies = local.json_config.attach_policies
  attach_managed_policies = local.json_config.attach_managed_policies
  attach_pb = local.json_config.permission_boundary # TODO - known bug; doesn't handle non-pb scenarios
}

data "template_file" "aws_iam_role_template" {
  template = jsonencode(local.assume_role_policy)
  vars = var.role_template_variable_map
}

resource "aws_iam_role" "aws_iam_rendered" {
  name  = "${local.project_prefix}-${local.environment}-${element(split(".", basename(var.role_config_file_path)),0)}" # TODO - nasty formatting; put into locals...or something
  path = "/" #TODO
  assume_role_policy  = "${data.template_file.aws_iam_role_template.rendered}"
  permissions_boundary = local.attach_pb == null ?  null : "arn:aws:iam::${lookup(var.role_template_variable_map, "aws_account_number")}:policy/${local.json_config.permission_boundary}"
}

# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html# TODO - handle aws built-in roles
resource "aws_iam_role_policy_attachment" "iam_policy_attach" {
  for_each = toset(local.json_config.attach_policies)
  role = "${aws_iam_role.aws_iam_rendered.name}"
  policy_arn = "arn:aws:iam::${lookup(var.role_template_variable_map, "aws_account_number")}:policy/${local.project_prefix}-${local.environment}-${each.value}"
  depends_on = [var.module_depends_on]
}

# Handles AWS Managed policies
resource "aws_iam_role_policy_attachment" "iam_managed_policy_attach" {
  for_each = toset(local.json_config.attach_managed_policies)
  role = "${aws_iam_role.aws_iam_rendered.name}"
  policy_arn = each.value
  depends_on = [var.module_depends_on]
}
