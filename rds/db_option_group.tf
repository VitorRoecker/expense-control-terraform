resource "aws_db_option_group" "default" {
  count = length(var.option_group_name) == 0 && module.this.enabled ? 1 : 0

  name_prefix          = "${module.this.id}${module.this.delimiter}"
  engine_name          = var.engine
  major_engine_version = local.major_engine_version
  tags                 = module.this.tags

  dynamic "option" {
    for_each = var.db_options
    content {
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
      option_name                    = option.value.option_name
      port                           = lookup(option.value, "port", null)
      version                        = lookup(option.value, "version", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}