resource "time_static" "created" {}

locals {
  org_id            = data.terraform_remote_state.org_structure.outputs.org_id
  billing_account   = data.terraform_remote_state.org_structure.outputs.billing_account
  logging_folder_id = data.terraform_remote_state.org_structure.outputs.logging
  geo_folder_id     = data.terraform_remote_state.org_structure.outputs.geo_folder
  created           = replace(split("T", time_static.created.rfc3339)[0], "-", "")
  labels            = merge(var.labels_logging, { "created" : local.created })
}

# Folder-level
resource "google_logging_folder_sink" "sink" {
  count            = local.is_folder_level ? 1 : 0
  name             = var.log_sink_name
  folder           = var.parent_resource_id
  filter           = var.filter
  include_children = var.include_children
  destination      = var.destination_uri
  dynamic "bigquery_options" {
    for_each = local.bigquery_options
    content {
      use_partitioned_tables = bigquery_options.value.use_partitioned_tables
    }
  }
}
