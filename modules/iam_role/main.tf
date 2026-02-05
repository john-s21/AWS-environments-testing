locals {
  # This fixes the "nasty formatting" issue by doing the naming logic here
  role_name = "${var.project_prefix}-${var.environment}-${var.role_name}"
}

# The Role Itself
resource "aws_iam_role" "this" {
  name                 = local.role_name
  assume_role_policy   = var.assume_role_policy
  
  # This fixes the "Permission Boundary" bug. 
  # If you don't provide a boundary, it won't crash anymore.
  permissions_boundary = var.permissions_boundary_arn != "" ? var.permissions_boundary_arn : null
  
  tags = {
    Environment = var.environment
    Project     = var.project_prefix
  }
}

# Attachment 1: Custom Policies (Like your SecretsManager policy)
resource "aws_iam_role_policy_attachment" "custom_policies" {
  for_each   = toset(var.custom_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# Attachment 2: Managed Policies (Like ReadOnlyAccess)
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each   = toset(var.managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}