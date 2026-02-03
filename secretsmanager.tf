// Variable Block //
variable "secret_names" {
  type        = map(any)
  description = "Name of the secret."
}

variable "secret_strings" {}

// Resource block //

resource "aws_secretsmanager_secret" "sm" {
  for_each                = tomap(var.secret_names)
  name                    = each.key
  description             = each.value
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "sm_version" {
  for_each      = tomap(var.secret_names)
  secret_id     = each.key
  secret_string = jsonencode(lookup(var.secret_strings, each.key, "{}"))
  depends_on    = [aws_secretsmanager_secret.sm]

  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
}
