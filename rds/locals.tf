locals {
  computed_major_engine_version = var.engine == "postgres" ? join(".", slice(split(".", var.engine_version), 0, 1)) : join(".", slice(split(".", var.engine_version), 0, 2))
  major_engine_version          = var.major_engine_version == "" ? local.computed_major_engine_version : var.major_engine_version

  subnet_ids_provided           = var.subnet_ids != null && length(var.subnet_ids) > 0
  db_subnet_group_name_provided = var.db_subnet_group_name != null && var.db_subnet_group_name != ""
  is_replica                    = try(length(var.replicate_source_db), 0) > 0
  password                      = var.database_password == null ? random_password.password.result : var.database_password
  user                          = var.database_user == null ? "user_${module.this.name}" : var.database_user
  db_name                       = var.database_name

  db_subnet_group_name = local.db_subnet_group_name_provided ? var.db_subnet_group_name : (
    local.is_replica ? null : (
    local.subnet_ids_provided ? join("", aws_db_subnet_group.default[*].name) : null)
  )

  availability_zone = var.multi_az ? null : var.availability_zone

  instance_address = join("", aws_db_instance.default[*].address)
}