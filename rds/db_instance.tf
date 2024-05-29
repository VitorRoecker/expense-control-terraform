resource "aws_db_instance" "default" {
  count = module.this.enabled ? 1 : 0

  identifier            = module.this.id
  db_name               = local.db_name
  username              = local.is_replica ? null : local.user
  password              = local.is_replica ? null : local.password
  port                  = var.database_port
  engine                = local.is_replica ? null : var.engine
  engine_version        = local.is_replica ? null : var.engine_version
  character_set_name    = var.charset_name
  instance_class        = var.instance_class
  allocated_storage     = local.is_replica ? null : var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_arn

  manage_master_user_password   = local.is_replica || local.password != null ? null : var.database_manage_master_user_password
  master_user_secret_kms_key_id = local.is_replica ? null : var.database_master_user_secret_kms_key_id

  vpc_security_group_ids = compact(
    concat(
      [join("", aws_security_group.default[*].id)],
      var.associate_security_group_ids
    )
  )

  db_subnet_group_name = local.db_subnet_group_name
  availability_zone    = local.availability_zone

  ca_cert_identifier          = var.ca_cert_identifier
  parameter_group_name        = length(var.parameter_group_name) > 0 ? var.parameter_group_name : join("", aws_db_parameter_group.default[*].name)
  option_group_name           = length(var.option_group_name) > 0 ? var.option_group_name : join("", aws_db_option_group.default[*].name)
  license_model               = var.license_model
  multi_az                    = var.multi_az
  storage_type                = var.storage_type
  iops                        = var.iops
  storage_throughput          = var.storage_type == "gp3" ? var.storage_throughput : null
  publicly_accessible         = var.publicly_accessible
  snapshot_identifier         = var.snapshot_identifier
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window
  skip_final_snapshot         = var.skip_final_snapshot
  copy_tags_to_snapshot       = var.copy_tags_to_snapshot
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  tags                        = module.this.tags
  deletion_protection         = var.deletion_protection
  final_snapshot_identifier   = length(var.final_snapshot_identifier) > 0 ? var.final_snapshot_identifier : module.final_snapshot_label.id
  replicate_source_db         = var.replicate_source_db
  timezone                    = var.timezone

  iam_database_authentication_enabled   = var.iam_database_authentication_enabled
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  dynamic "restore_to_point_in_time" {
    for_each = var.snapshot_identifier == null && var.restore_to_point_in_time != null ? [1] : []

    content {
      restore_time                             = lookup(var.restore_to_point_in_time, "restore_time", null)
      source_db_instance_identifier            = lookup(var.restore_to_point_in_time, "source_db_instance_identifier", null)
      source_db_instance_automated_backups_arn = lookup(var.restore_to_point_in_time, "source_db_instance_automated_backups_arn", null)
      source_dbi_resource_id                   = lookup(var.restore_to_point_in_time, "source_dbi_resource_id", null)
      use_latest_restorable_time               = lookup(var.restore_to_point_in_time, "use_latest_restorable_time", null)
    }
  }

  depends_on = [
    aws_db_subnet_group.default,
    aws_security_group.default,
    aws_db_parameter_group.default,
    aws_db_option_group.default
  ]

  lifecycle {
    ignore_changes = [
      snapshot_identifier,
    ]
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}