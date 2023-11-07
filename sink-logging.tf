// This module is for Data Access Log Bucket
resource "google_logging_folder_sink" "data-sink" {
  provider         = google.create_dataset
  name             = var.log_sink_data_access
  description      = "Log sink for Data logs"
  destination      = "storage.googleapis.com/${google_storage_bucket.data-bucket.name}"
  filter           = "cloudaudit.googleapis.com%2Fdata_access"
  folder           = local.geo_folder_id
  include_children = true
}

resource "google_storage_bucket" "data-bucket" {
  provider = google.create_dataset
  name     = "${var.logging_bucket_data_access}-${random_id.random_project_id_suffix.hex}"
  project  = module.prj-log.project_id

  location                    = var.sink_bucket_location
  force_destroy               = true
  uniform_bucket_level_access = true
  encryption {
    default_kms_key_name = local.kms_key_logging
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age        = var.expiration_data_access
      with_state = "ANY"
    }
  }
  depends_on = [
    google_kms_crypto_key_iam_member.data_encrypto_key
  ]
}

resource "google_storage_bucket_iam_member" "data_access_sink_member" {
  provider = google.create_dataset
  bucket   = google_storage_bucket.data-bucket.name
  role     = "roles/storage.objectCreator"
  member   = google_logging_folder_sink.data-sink.writer_identity
}