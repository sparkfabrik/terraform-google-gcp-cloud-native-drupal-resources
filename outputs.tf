locals {
  all_data = {
    for p in var.drupal_projects_list : "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" => {
      # Add the values you want to store for each project here
      # Example:
      namespace          = p.kubernetes_namespace == null ? "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" : p.kubernetes_namespace
      helm_release_name  = p.helm_release_name == null ? "drupal-${p.release_branch_name}-${p.project_id}" : p.helm_release_name
      bucket_credentials = try(module.drupal_buckets[0].buckets_access_credentials["${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}-drupal"], null)
      database_credentials = try(
        [for cred in module.drupal_databases_and_users[0].sql_users_creds : cred
      if cred.database == replace("${p.project_name}_${p.gitlab_project_id}_${p.release_branch_name}_dp", "-", "_")][0], null)
      kubernetes_bucket_secret   = try(local.bucket_secrets_map["${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}"], null)
      kubernetes_database_secret = try(local.database_secrets_map["${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}"], null)
    }
  }

  bucket_secrets_map = {
    for o in local.drupal_buckets_list : replace(o.name, "-drupal", "") => {
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
        kubernetes_secret.database_secret_name[replace("${p.project_name}_${p.gitlab_project_id}_${p.release_branch_name}_dp", "-", "_")].metadata[0].name,
      null)
      namespace = try(
        kubernetes_secret.database_secret_name[replace("${p.project_name}_${p.gitlab_project_id}_${p.release_branch_name}_dp", "-", "_")].metadata[0].namespace,
        null
      )
    }
  }
}


output "drupal_all_data" {
  description = "All data for each Drupal project."
  value       = local.all_data
}

output "drupal_all_bucket_credentials" {
  description = "Bucket credentials for each Drupal project"
  sensitive   = true
  value = {
    for key, value in local.all_data : key => value.bucket_credentials
  }
}

output "drupal_all_database_credentials" {
  description = "Database credentials for each Drupal project"
  sensitive   = true
  value = {
    for key, value in local.all_data : key => value.database_credentials
  }
}

output "drupal_all_bucket_secrets" {
  description = "Bucket kubernetes secrets for each Drupal project"
  sensitive   = true
  value = {
    for key, value in local.all_data : key => value.kubernetes_bucket_secret
  }
}

output "drupal_all_database_secrets" {
  description = "Database kubernetes secrets for each Drupal project"
  sensitive   = true
  value = {
    for key, value in local.all_data : key => value.kubernetes_database_secret
  }
}

output "drupal_all_namespaces" {
  description = "Namespace for each Drupal project"
  value = {
    for key, value in local.all_data : key => value.namespace
  }
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
