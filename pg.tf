# SAS placement group
resource "aws_placement_group" "sas" {
  count    = var.use_placement_group == true ? 1 : 0
  name     = "${var.prefix}-pg"
  strategy = "cluster"
}
