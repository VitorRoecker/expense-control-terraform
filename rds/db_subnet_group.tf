resource "aws_db_subnet_group" "default" {
  count = module.this.enabled && local.subnet_ids_provided && !local.db_subnet_group_name_provided ? 1 : 0

  name       = module.this.id
  subnet_ids = var.subnet_ids
  tags       = module.this.tags
}
