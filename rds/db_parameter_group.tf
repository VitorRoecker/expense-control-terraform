resource "aws_db_parameter_group" "default" {
  count = length(var.parameter_group_name) == 0 && module.this.enabled ? 1 : 0

  name_prefix = "${module.this.id}${module.this.delimiter}"
  family      = var.db_parameter_group
  tags        = module.this.tags

  dynamic "parameter" {
    for_each = var.db_parameter
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}