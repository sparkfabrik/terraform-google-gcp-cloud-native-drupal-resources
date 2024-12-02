locals {
  grouped_resources = {
    for p in var.drupal_projects_list : "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" => p...
  }

  all_data = "pippo"

  # all_data = {
  #   for p in var.drupal_projects_list : distinct("${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}") => {

  #   }
  #   for r in local.grouped_resources : r.helm_release_name => {
  #     #for h in r : h.helm_release_name != null ? h.helm_release_name : "drupal-${h.release_branch_name}-${h.gitlab_project_id}" => {
  #     namespace = "test"
  #     #}
  #     #namespace = r.kubernetes_namespace == null ? "${r.project_name}-${r.gitlab_project_id}-${r.release_branch_name}" : r.kubernetes_namespace

  #   }
  # }

  #echo 'module.production_db.grouped_resources["zambon-website-304-main"][0].helm_release_name' | terraform console


  # helm_releases = {
  #   for r in var.drupal_projects_list : r.helm_release_name != null ? r.helm_release_name : "drupal-${r.release_branch_name}-${r.gitlab_project_id}" => {
  #     namespace = r.kubernetes_namespace == null ? "${r.project_name}-${r.gitlab_project_id}-${r.release_branch_name}" : p.kubernetes_namespace
  #   }
  #   if "${r.project_name}-${r.gitlab_project_id}-${r.release_branch_name}" == "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}"
  # }


  # all_data = {
  #   for p in var.drupal_projects_list : "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}-${p.helm_release_name != null ? p.helm_release_name : "drupal-${p.release_branch_name}-${p.gitlab_project_id}"}" => {
  #     # Add the values you want to store for each project here
  #     # Example:
  #     namespace          = p.kubernetes_namespace == null ? "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" : p.kubernetes_namespace
  #     helm_release_name  = p.helm_release_name == null ? "drupal-${p.release_branch_name}-${p.gitlab_project_id}" : p.helm_release_name
  #     bucket_credentials = try(module.drupal_buckets[0].buckets_access_credentials["${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}-drupal"], null)
  #     database_credentials = try(
  #       [for cred in module.drupal_databases_and_users[0].sql_users_creds : cred
  #         if cred.database == (
  #           p.database_name != null ?
  #           p.database_name :
  #           replace("${p.project_name}_${p.gitlab_project_id}_${p.release_branch_name}_dp", "-", "_")
  #         )
  #       ][0],
  #     null)
  #     kubernetes_bucket_secret   = try(local.bucket_secrets_map["${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}"], null)
  #     kubernetes_database_secret = try(local.database_secrets_map["${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}-${p.helm_release_name != null ? p.helm_release_name : "drupal-${p.release_branch_name}-${p.gitlab_project_id}"}"], null)
  #   }
  # }

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
          p.helm_release_name != null ? "${p.helm_release_name}" : replace("${p.project_name}_${p.gitlab_project_id}_${p.release_branch_name}_dp", "-", "_")
        ].metadata[0].name,
        null
      )
      namespace = try(
        kubernetes_secret.database_secret_name[
          p.helm_release_name != null ? "${p.helm_release_name}" : replace("${p.project_name}_${p.gitlab_project_id}_${p.release_branch_name}_dp", "-", "_")
        ].metadata[0].namespace,
        null
      )
    }
  }
}

output "grouped_resources" {
  value = local.grouped_resources
}

output "database_credentials_map" {
  value = module.drupal_databases_and_users[0].sql_users_creds

}

output "bucket_secrets_map" {
  value = local.bucket_secrets_map
}

output "database_secrets_map" {
  value = local.database_secrets_map
}

output "drupal_apps_all_data" {
  description = "All data for each Drupal project."
  value       = local.all_data
}

# output "drupal_apps_all_bucket_credentials" {
#   description = "Bucket credentials for each Drupal project"
#   sensitive   = true
#   value = {
#     for key, value in local.all_data : key => value.bucket_credentials
#   }
# }

# output "drupal_apps_all_database_credentials" {
#   description = "Database credentials for each Drupal project"
#   sensitive   = true
#   value = {
#     for key, value in local.all_data : key => value.database_credentials
#   }
# }

# output "drupal_apps_all_bucket_secrets" {
#   description = "Bucket kubernetes secrets for each Drupal project"
#   sensitive   = true
#   value = {
#     for key, value in local.all_data : key => value.kubernetes_bucket_secret
#   }
# }

# output "drupal_apps_all_database_secrets" {
#   description = "Database kubernetes secrets for each Drupal project"
#   sensitive   = true
#   value = {
#     for key, value in local.all_data : key => value.kubernetes_database_secret
#   }
# }

# output "drupal_apps_all_namespaces" {
#   description = "Namespace for each Drupal project"
#   value = {
#     for key, value in local.all_data : key => value.namespace
#   }
# }

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
