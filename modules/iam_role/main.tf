locals {
  role_name = "${var.project_prefix}-${var.environment}-${var.role_name}"
}

# 1. The Role
resource "aws_iam_role" "this" {
  name                 = local.role_name
  assume_role_policy   = var.assume_role_policy
  permissions_boundary = var.permissions_boundary_arn != "" ? var.permissions_boundary_arn : null
  
  tags = {
    Environment = var.environment
    Project     = var.project_prefix
  }
}

# 2. Attachment: Custom Policies (Using count to avoid "known after apply" errors)
resource "aws_iam_role_policy_attachment" "custom_policies" {
  count      = length(var.custom_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = var.custom_policy_arns[count.index]
}

# 3. Attachment: Managed Policies
resource "aws_iam_role_policy_attachment" "managed_policies" {
  count      = length(var.managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = var.managed_policy_arns[count.index]
}