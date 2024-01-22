# SAS cluster placement group for CAS
resource "aws_placement_group" "sas_pg_cas" {
  count    = var.use_placement_group == true ? 1 : 0
  name     = "${var.prefix}-pg-cas"
  strategy = "cluster"
}
