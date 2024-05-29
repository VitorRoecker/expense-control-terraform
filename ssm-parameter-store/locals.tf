locals {
  enabled                       = module.this.enabled
  parameter_write               = local.enabled && ! var.ignore_value_changes ? { for e in var.parameter_write : e.name => merge(var.parameter_write_defaults, e) } : {}
  parameter_write_ignore_values = local.enabled && var.ignore_value_changes ? { for e in var.parameter_write : e.name => merge(var.parameter_write_defaults, e) } : {}
  parameter_read                = local.enabled ? var.parameter_read : []
  
  name_list = compact(concat(keys(local.parameter_write), keys(local.parameter_write_ignore_values), local.parameter_read))

  value_list = compact(
    concat(
      [for p in aws_ssm_parameter.default : p.value], [for p in aws_ssm_parameter.ignore_value_changes : p.value], data.aws_ssm_parameter.read.*.value
    )
  )

  arn_list = compact(
    concat(
      [for p in aws_ssm_parameter.default : p.arn], [for p in aws_ssm_parameter.ignore_value_changes : p.arn], data.aws_ssm_parameter.read.*.arn
    )
  )

}