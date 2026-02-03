locals {
  environment = lookup(var.policy_template_variable_map, "environment")
  project_prefix = lookup(var.policy_template_variable_map, "project_prefix")
}

data "template_file" "aws_iam_policy_template" {
  template = "${file("${var.user_policy_file_path}")}"
  vars = var.policy_template_variable_map
}

resource "aws_iam_policy" "aws_iam_user_policy_rendered" {
  name  = "${local.project_prefix}-${local.environment}-${element(split(".", basename(var.user_policy_file_path)),0)}" # TODO - nasty formatting; put into locals...or something
  policy = "${data.template_file.aws_iam_policy_template.rendered}"
}
