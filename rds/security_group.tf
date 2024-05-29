resource "aws_security_group" "default" {
  count = module.this.enabled ? 1 : 0

  name        = module.this.id
  description = "Allow inbound traffic from the security groups"
  vpc_id      = var.vpc_id
  tags        = module.this.tags
}
