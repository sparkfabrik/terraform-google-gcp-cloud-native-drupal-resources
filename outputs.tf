locals {
  grouped_resources = {
    for p in var.drupal_projects_list : "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" => p...
  }

  all_data = {
    for key, resources in local.grouped_resources : key => {
      for r in resources : (r.helm_release_name != null ? r.helm_release_name : "drupal-${r.release_branch_name}-${r.gitlab_project_id}") => {
        namespace          = r.kubernetes_namespace == null ? "${r.project_name}-${r.gitlab_project_id}-${r.release_branch_name}" : r.kubernetes_namespace
        bucket_credentials = try(module.drupal_buckets[0].buckets_access_credentials["${r.project_name}-${r.gitlab_project_id}-${r.release_branch_name}-drupal"], null)
        database_credentials = try(
          [for cred in module.drupal_databases_and_users[0].sql_users_creds : cred
            if cred.database == (
              r.database_name != null ?
              r.database_name :
              replace("${r.project_name}_${r.gitlab_project_id}_${r.release_branch_name}_dp", "-", "_")
        )][0], null)
        kubernetes_bucket_secret   = try(local.bucket_secrets_map["${r.project_name}-${r.gitlab_project_id}-${r.release_branch_name}"], null)
        kubernetes_database_secret = try(local.database_secrets_map["${r.project_name}-${r.gitlab_project_id}-${r.release_branch_name}-${r.helm_release_name != null ? r.helm_release_name : "drupal-${r.release_branch_name}-${r.gitlab_project_id}"}"], null)
      }
    }
  }

  bucket_secrets_map = var.create_buckets ? {
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
  } : {}

  database_secrets_map = {
    for p in var.drupal_projects_list : "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}-${p.helm_release_name != null ? p.helm_release_name : "drupal-${p.release_branch_name}-${p.gitlab_project_id}"}" => {
      secret_name = try(
        kubernetes_secret.database_secret_name[
          p.helm_release_name != null ? p.helm_release_name : replace("${p.project_name}_${p.gitlab_project_id}_${p.release_branch_name}_dp", "-", "_")
        ].metadata[0].name,
        null
      )
      namespace = try(
        kubernetes_secret.database_secret_name[
          p.helm_release_name != null ? p.helm_release_name : replace("${p.project_name}_${p.gitlab_project_id}_${p.release_branch_name}_dp", "-", "_")
        ].metadata[0].namespace,
        null
      )
    }
  }
}

output "drupal_apps_all_data" {
  description = "All data for each Drupal project."
  value       = local.all_data
}

output "drupal_apps_all_namespaces" {
  description = "Map of all Kubernetes namespaces used by Drupal apps, indexed same as all_data"
  value = {
    for key, values in local.all_data : key => {
      for helm_release, data in values : helm_release => data.namespace
    }
  }
}

output "drupal_apps_all_bucket_credentials" {
  description = "Bucket credentials for each Drupal project, indexed same as all_data"
  sensitive   = true
  value = {
    for key, values in local.all_data : key => {
      for helm_release, data in values : helm_release => data.bucket_credentials
    }
  }
}

output "drupal_apps_all_bucket_secrets" {
  description = "Bucket kubernetes secrets for each Drupal project, indexed same as all_data"
  sensitive   = true
  value = {
    for key, values in local.all_data : key => {
      for helm_release, data in values : helm_release => data.kubernetes_bucket_secret
    }
  }
}

output "drupal_apps_all_database_credentials" {
  description = "Database credentials for each Drupal project, indexed same as all_data"
  sensitive   = true
  value = {
    for key, values in local.all_data : key => {
      for helm_release, data in values : helm_release => data.database_credentials
    }
  }
}

output "drupal_apps_all_database_secrets" {
  description = "Database kubernetes secrets for each Drupal project, indexed same as all_data"
  sensitive   = true
  value = {
    for key, values in local.all_data : key => {
      for helm_release, data in values : helm_release => data.kubernetes_database_secret
    }
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

output "namespaces_network_policy" {
  description = "Namespaces with network policy enabled."
  value = {
    for namespace, project in local.distinct_namespaces : namespace => project.network_policy == "" ? "none" : project.network_policy
  }
}
