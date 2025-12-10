/*
 *  Database, user and bucket list for Drupal projects. If not specified, the
 *  name of the database, user and bucket will be generated using the project
 *  name.
 *  Specifying a database name, user name or bucket name is suggested only when
 *  you want to import in Terraform or move in the module existing resources.
 */

locals {
  drupal_database_and_user_list = [
    for p in var.drupal_projects_list : {
      namespace           = p.kubernetes_namespace == null ? "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" : p.kubernetes_namespace
      release_branch_name = p.release_branch_name
      database            = p.database_name != null ? p.database_name : "${replace(p.project_name, "-", "_")}_${p.gitlab_project_id}_${p.release_branch_name}_dp"
      user                = p.database_user_name != null ? p.database_user_name : "${replace(p.project_name, "-", "_")}_${p.gitlab_project_id}_${p.release_branch_name}_dp_u"
      host                = p.database_host != null ? p.database_host : null
      project_id          = p.gitlab_project_id
      helm_release_name   = p.helm_release_name
      port                = p.database_port
    }
  ]

  drupal_buckets_list = [
    for p in var.drupal_projects_list : {
      name                          = p.bucket_name != null ? p.bucket_name : "${replace(p.project_name, "_", "-")}-${p.gitlab_project_id}-${p.release_branch_name}-drupal"
      force_destroy                 = p.bucket_force_destroy
      append_random_suffix          = p.bucket_append_random_suffix
      location                      = p.bucket_location != null ? p.bucket_location : var.region
      storage_class                 = p.bucket_storage_class
      enable_versioning             = p.bucket_enable_versioning
      enable_disaster_recovery      = p.bucket_enable_disaster_recovery
      set_all_users_as_viewer       = p.bucket_set_all_users_as_viewer
      labels                        = p.bucket_labels
      tag_list                      = p.bucket_tag_list
      bucket_obj_adm                = p.bucket_obj_adm
      bucket_obj_vwr                = p.bucket_obj_vwr
      namespace                     = p.kubernetes_namespace == null ? "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" : p.kubernetes_namespace
      release_branch_name           = p.release_branch_name
      host                          = p.bucket_host
      project_id                    = p.gitlab_project_id
      helm_release_name             = p.helm_release_name
      legacy_public_files_path      = p.bucket_legacy_public_files_path
      soft_delete_retention_seconds = p.bucket_soft_delete_retention_seconds
    }
  ]

  drupal_redis_list = [
    for p in var.drupal_projects_list : {
      namespace           = p.kubernetes_namespace == null ? "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" : p.kubernetes_namespace
      release_branch_name = p.release_branch_name
      host                = p.redis_host != "" ? p.redis_host : var.redis_host
      port                = p.redis_port != null ? p.redis_port : var.redis_port
      project_id          = p.gitlab_project_id
      helm_release_name   = p.helm_release_name
    }
  ]

  namespace_list = [
    for p in var.drupal_projects_list : merge(p, {
      namespace = p.kubernetes_namespace == null ? "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" : p.kubernetes_namespace
      labels = merge(
        { "name" = p.kubernetes_namespace == null ? "${p.project_name}-${p.gitlab_project_id}-${p.release_branch_name}" : p.kubernetes_namespace },
        p.kubernetes_namespace_labels,
        var.default_k8s_labels
      )
    })
  ]

  # Create a map of distinct namespaces with their corresponding project information. This is used to create Kubernetes namespaces and NetworkPolicies.
  distinct_namespaces = {
    for i in distinct([for n in local.namespace_list : n.namespace]) : i => [
      for p in local.namespace_list : p if p.namespace == i
    ][0]
  }
}

# Add new databases and users to the CloudSQL master instance.
module "drupal_databases_and_users" {
  count                             = trimspace(var.cloudsql_instance_name) != "" && trimspace(var.cloudsql_privileged_user_name) != "" && trimspace(var.cloudsql_privileged_user_password) != "" && var.create_databases_and_users == true ? 1 : 0
  source                            = "github.com/sparkfabrik/terraform-google-gcp-mysql-db-and-user-creation-helper?ref=0.5.1"
  project_id                        = var.project_id
  region                            = var.region
  cloudsql_instance_name            = var.cloudsql_instance_name
  cloudsql_privileged_user_name     = var.cloudsql_privileged_user_name
  cloudsql_privileged_user_password = var.cloudsql_privileged_user_password
  database_and_user_list            = local.drupal_database_and_user_list
  permissions_refresh_id            = var.permissions_refresh_id
}

# ----------------------
# Drupal buckets
# ----------------------
# Add Drupal buckets and Hmac-key credentials with versioning and disaster
# recovery enabled by default.
module "drupal_buckets" {
  count                                     = var.create_buckets == true ? 1 : 0
  source                                    = "github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper?ref=0.11.0"
  project_id                                = var.project_id
  buckets_list                              = local.drupal_buckets_list
  logging_bucket_name                       = var.logging_bucket_name
  disaster_recovery_bucket_location         = var.bucket_disaster_recovery_location
  global_tags                               = var.global_tags
  additional_transfer_job_excluded_prefixes = var.bucket_additional_transfer_job_excluded_prefixes
}

resource "kubernetes_namespace" "namespace" {
  for_each = var.use_existing_kubernetes_namespaces ? {} : local.distinct_namespaces

  metadata {
    name   = each.value.namespace
    labels = each.value.labels
  }
}

data "kubernetes_namespace" "namespace" {
  for_each = var.use_existing_kubernetes_namespaces ? local.distinct_namespaces : {}
  metadata {
    name = each.value.namespace
  }
}

resource "kubernetes_network_policy_v1" "this" {
  for_each = {
    for namespace, project in local.distinct_namespaces : namespace => project if project.network_policy != ""
  }

  metadata {
    name      = "network-policy-${each.value.network_policy}"
    namespace = var.use_existing_kubernetes_namespaces ? data.kubernetes_namespace.namespace[each.key].metadata[0].name : resource.kubernetes_namespace.namespace[each.key].metadata[0].name
  }

  spec {
    pod_selector {}

    policy_types = ["Ingress"]

    ingress {
      dynamic "from" {
        for_each = each.value.network_policy == "isolated" ? { "isolated" : true } : {}
        content {
          pod_selector {}
        }
      }
      dynamic "from" {
        for_each = each.value.network_policy == "restricted" ? { "restricted" : true } : {}
        content {}
      }
    }
  }
}

resource "kubernetes_network_policy_v1" "acme" {
  for_each = {
    for namespace, project in local.distinct_namespaces : namespace => project if project.network_policy != ""
  }

  metadata {
    name      = "network-policy-allow-acme"
    namespace = var.use_existing_kubernetes_namespaces ? data.kubernetes_namespace.namespace[each.key].metadata[0].name : resource.kubernetes_namespace.namespace[each.key].metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = each.value.network_policy_acme_labels
    }

    policy_types = ["Ingress"]

    ingress {
      ports {
        port     = each.value.network_policy_acme_port
        protocol = "TCP"
      }
    }
  }
}
