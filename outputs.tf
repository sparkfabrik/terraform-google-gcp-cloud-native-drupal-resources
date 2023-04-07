output "drupal_apps_database_credentials" {
  sensitive   = true
  description = "Drupal apps database credentials for each Drupal project."
  value = trimspace(var.cloudsql_instance_name) != "" && trimspace(var.cloudsql_privileged_user_name) != "" && (trimspace(var.cloudsql_privileged_user_password) != "" && var.create_databases_and_users == true) ? module.drupal_databases_and_users.sql_users_creds : []
}

output "drupal_apps_bucket_credentials" {
  sensitive   = true
  description = "Drupal apps bucket credentials for each Drupal project."
  value       = var.create_buckets == true && !(local.module_drupal_buckets_is_empty) ? module.drupal_buckets.buckets_access_credentials : []
}
