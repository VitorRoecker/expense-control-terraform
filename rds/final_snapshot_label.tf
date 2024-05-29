module "final_snapshot_label" {
  source     = "../label"
  attributes = ["final", "snapshot"]
  context    = module.this.context
}