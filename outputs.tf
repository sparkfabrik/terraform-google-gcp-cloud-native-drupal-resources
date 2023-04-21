output "drupal_apps_database_credentials" {
  sensitive   = true
  description = "Drupal apps database credentials for each Drupal project."
  value       = toset(module.drupal_databases_and_users[*].sql_users_creds)
}

output "drupal_apps_bucket_credentials" {
  sensitive   = true
  description = "Drupal apps bucket credentials for each Drupal project."
  value       = module.drupal_buckets[*].buckets_access_credentials
}

output "drupal_apps_helm_values_for_buckets" {
  sensitive = true
  value     = data.template_file.helm_values_for_buckets
}

output "drupal_apps_helm_values_for_databases" {
  sensitive = true
  value     = data.template_file.helm_values_for_databases
}
