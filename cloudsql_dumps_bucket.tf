# --------------------------------
# CloudSQL databases dumps bucket.
# --------------------------------
# Retrieve the CloudSQL instance.
data "google_sql_database_instance" "cloudsql_instance" {
  count   = var.create_clousql_dumps_bucket ? 1 : 0
  name    = var.cloudsql_instance_name
  project = var.project_id
}

# Create a random suffix for the bucket name.
resource "random_id" "cloudsql_dumps_bucket_name_suffix" {
  count       = var.create_clousql_dumps_bucket ? 1 : 0
  byte_length = 4
}

resource "google_storage_bucket" "cloudsql_dumps" {
  count         = var.create_clousql_dumps_bucket ? 1 : 0
  name          = "${var.project_id}-cloudsql-dumps-${random_id.cloudsql_dumps_bucket_name_suffix[0].hex}"
  location      = var.region
  storage_class = "NEARLINE"

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 180
    }
  }

  versioning {
    enabled = false
  }
}

# The service account of CloudSQL must be authorized to write on the bucket.
# This operation is automatic when you export a database to a bucket from the
# Cloud SQL console, but it must be done manually if you want to use the
# `gcloud sql export` command.
resource "google_storage_bucket_iam_member" "cloudsql_dumps_bucket_writer" {
  count  = var.create_clousql_dumps_bucket ? 1 : 0
  bucket = google_storage_bucket.cloudsql_dumps[0].name
  role   = "roles/storage.legacyBucketWriter"
  member = "serviceAccount:${data.google_sql_database_instance.cloudsql_instance[0].service_account_email_address}"
}

# Retrieve the tag keys for the tags that we are passing to the resources.
# We split the friendly name we are passing to the module, to get the tag key shortname
# as the index 0, and the tag value shortname as the index 1.
# The friendly name is in the form <TAG_KEY_SHORTNAME>/<TAG_VALUE_SHORTNAME>
data "google_tags_tag_key" "tag_keys" {
  for_each   = var.create_clousql_dumps_bucket ? toset(var.global_tags) : []
  parent     = "projects/${var.project_id}"
  short_name = split("/", each.value)[0]
}

# To bind a tag to a resource, we need to know the tag value ID (something as
# "tagValues/281483307043046"), that we can retrieve from this data source.
data "google_tags_tag_value" "tag_values" {
  for_each   = var.create_clousql_dumps_bucket ? toset(var.global_tags) : []
  parent     = data.google_tags_tag_key.tag_keys[each.value].id
  short_name = split("/", each.value)[1]
}

# Bind tags to buckets.
resource "google_tags_location_tag_binding" "binding" {
  for_each  = var.create_clousql_dumps_bucket ? toset(var.global_tags) : []
  parent    = "//storage.googleapis.com/projects/_/buckets/${google_storage_bucket.cloudsql_dumps[0].name}"
  location  = google_storage_bucket.cloudsql_dumps[0].location
  tag_value = data.google_tags_tag_value.tag_values[each.value].id
}
