locals {
  # Database, user and bucket list for Drupal projects. If not specified, the
  # name of the database, user and bucket will be generated using the project
  # name.
  # Specifying a database name, user name or bucket name is suggested only when
  # you want to import in Terraform or move in the module existing resources.

  drupal_database_and_user_list = [
    for p in var.drupal_projects_list : {
      database = p.database_name != null ? p.database_name : "${replace(p.project_name, "-", "_")}_drupal"
      user     = p.database_user_name != null ? p.database_user_name : "${replace(p.project_name, "-", "_")}_drupal_u"
    }
  ]

  drupal_buckets_list = [
    for p in var.drupal_projects_list : {
      name                     = p.bucket_name != null ? p.bucket_name : "${replace(p.project_name, "_", "-")}-drupal"
      append_random_suffix     = p.bucket_append_random_suffix
      location                 = p.bucket_location != null ? p.bucket_location : var.region
      storage_class            = p.bucket_storage_class
      enable_versioning        = p.bucket_enable_versioning
      enable_disaster_recovery = p.bucket_enable_disaster_recovery
    }
  ]
}

# Add new databases and users to the CloudSQL master instance.
module "drupal_databases_and_users" {
  source                            = "sparkfabrik/gcp-mysql-db-and-user-creation-helper/google"
  version                           = ">= 0.3"
  project_id                        = var.project_id
  region                            = var.region
  cloudsql_instance_name            = var.cloudsql_instance_name
  cloudsql_privileged_user_name     = var.cloudsql_privileged_user_name
  cloudsql_privileged_user_password = var.cloudsql_privileged_user_password
  database_and_user_list            = local.drupal_database_and_user_list
}

# ----------------------
# Drupal buckets
# ----------------------
# Add Drupal buckets and Hmac-key credentials with versioning and disaster
# recovery enabled by default.
module "drupal_buckets" {
  source              = "sparkfabrik/gcp-application-bucket-creation-helper/google"
  version             = ">= 0.1.0"
  project_id          = var.project_id
  buckets_list        = local.drupal_buckets_list
  logging_bucket_name = var.logging_bucket_name
}
