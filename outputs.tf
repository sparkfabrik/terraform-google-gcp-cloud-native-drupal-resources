locals {
  all_data = {
    for p in var.drupal_projects_list : "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" => {
      # Add the values you want to store for each project here
      # Example:
      namespace          = p.kubernetes_namespace == null ? "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" : p.kubernetes_namespace
      bucket_credentials = module.drupal_buckets[0].buckets_access_credentials["${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}-drupal"]
      kubernetes_bucket_secret = try(
        local.bucket_secrets_map["${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}"],
        null
      )
      database_credentials = try(
        [
          for cred in module.drupal_databases_and_users[0].sql_users_creds : cred
          if cred.database == "${p.project_name}_${p.gitlab_project_id}_${p.release_branch_name}_dp"
        ][0],
        null
      )
      kubernetes_database_secret = try(
        local.database_secrets_map["${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}"],
        null
      )
    }
  }
  bucket_secrets_map = {
    for o in local.drupal_buckets_list : "${replace(o.name, "-drupal", "")}" => {
      secret_name = try(
        kubernetes_secret.bucket_secret_name[o.name].metadata[0].name,
        null
      )
      namespace = try(
        kubernetes_secret.bucket_secret_name[o.name].metadata[0].namespace,
        null
      )
    }
  }
  database_secrets_map = {
    for p in var.drupal_projects_list : "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" => {
      secret_name = try(
        kubernetes_secret.database_secret_name["${p.project_name}_${p.gitlab_project_id}_${p.release_branch_name}_dp"].metadata[0].name,
      null)
      namespace = try(
        kubernetes_secret.database_secret_name["${p.project_name}_${p.gitlab_project_id}_${p.release_branch_name}_dp"].metadata[0].namespace,
        null
      )
    }
  }
}

output "all_data_output" {
  description = "All data for each Drupal project."
  value       = local.all_data
}

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

output "details_of_used_tag_keys" {
  description = "Details of the tag keys passed to this module."
  value       = module.drupal_buckets[*].details_of_used_tag_keys
}

output "details_of_used_tag_values" {
  description = "Details of the tag values passed to this module."
  value       = module.drupal_buckets[*].details_of_used_tag_values
}

output "drupal_buckets_names_list" {
  description = "The list with the names of the Drupal buckets managed by this module."
  value       = flatten(module.drupal_buckets[*].generated_bucket_names)
}

output "cloudsql_dumps_bucket_name" {
  description = "CloudSQL dumps bucket name."
  value       = local.cloudsql_dumps_bucket_name
}
