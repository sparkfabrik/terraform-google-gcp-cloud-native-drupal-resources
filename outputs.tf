output "drupal_apps_database_credentials" {
  sensitive   = true
  description = "Drupal apps database credentials for each Drupal project."
  value       = trimspace(var.cloudsql_instance_name) != "" && trimspace(var.cloudsql_privileged_user_name) != "" && (trimspace(var.cloudsql_privileged_user_password) != "" && var.create_databases_and_users == true) ? toset(module.drupal_databases_and_users[0].sql_users_creds) : []
}

output "drupal_apps_bucket_credentials" {
  sensitive   = true
  description = "Drupal apps bucket credentials for each Drupal project."
  value       = var.create_buckets == true ? module.drupal_buckets[0].buckets_access_credentials : []
}

output "helm_values_for_buckets" {
  sensitive = true
  value     = data.template_file.helm_values_for_buckets
}

output "helm_values_for_databases" {
  sensitive = true
  value     = data.template_file.helm_values_for_databases
}
