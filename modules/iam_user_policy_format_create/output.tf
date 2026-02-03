output "aws_iam_policy_output" {
    description = "Formatted iam policy"
    value = aws_iam_policy.aws_iam_user_policy_rendered
}
