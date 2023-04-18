output "drupal_apps_database_credentials" {
  sensitive   = true
  description = "Drupal apps database credentials for each Drupal project."
  value       = module.drupal_resources.drupal_apps_database_credentials
}

output "drupal_apps_bucket_credentials" {
  sensitive   = true
  description = "Drupal apps bucket credentials for each Drupal project."
  value       = module.drupal_resources.drupal_apps_bucket_credentials
}

output "helm_values_for_buckets" {
  sensitive   = true
  description = "Helm values for buckets to be entered into the gitlab pipeline"
  value       = module.drupal_resources.helm_values_for_buckets
}

output "helm_values_for_databases" {
  sensitive   = true
  description = "Helm values for databases to be entered into the gitlab pipeline"
  value       = module.drupal_resources.helm_values_for_databases
}
