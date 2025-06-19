locals {
  map_of_drupal_buckets = var.create_buckets == true ? {
    for o in local.drupal_buckets_list : o.name => o
  } : {}

  map_of_drupal_databases = (
    trimspace(var.cloudsql_instance_name) != "" &&
    trimspace(var.cloudsql_privileged_user_name) != "" &&
    trimspace(var.cloudsql_privileged_user_password) != "" &&
    var.create_databases_and_users == true
    ) ? {
    for o in local.drupal_database_and_user_list : o.database => o
  } : {}

  map_of_output_drupal_databases = (
    trimspace(var.cloudsql_instance_name) != "" &&
    trimspace(var.cloudsql_privileged_user_name) != "" &&
    trimspace(var.cloudsql_privileged_user_password) != "" &&
    var.create_databases_and_users == true
    ) ? {
    for o in module.drupal_databases_and_users[0].sql_users_creds : o.database => o
  } : {}

  drupal_databases_keys = (
    var.create_databases_and_users == true ?
    [
      for o in local.drupal_database_and_user_list : o.database
      if trimspace(o.namespace) != ""
    ] : []
  )
}

resource "kubernetes_secret" "bucket_secret_name" {
  for_each = local.map_of_drupal_buckets

  metadata {
    name        = each.value.helm_release_name == null ? "drupal-${each.value.release_branch_name}-${each.value.project_id}-bucket" : "${each.value.helm_release_name}-bucket"
    namespace   = var.use_existing_kubernetes_namespaces ? each.value.namespace : kubernetes_namespace.namespace[each.value.namespace].metadata[0].name
    annotations = {}
    labels      = var.default_k8s_labels
  }
  data = {
    endpoint         = each.value.host
    name             = module.drupal_buckets[0].buckets_access_credentials[each.key].bucket_name
    username         = module.drupal_buckets[0].buckets_access_credentials[each.key].access_id
    password         = module.drupal_buckets[0].buckets_access_credentials[each.key].secret
    nginx_osb_bucket = "https://${each.value.host}/${module.drupal_buckets[0].buckets_access_credentials[each.key].bucket_name}${each.value.legacy_public_files_path}"
  }
}

resource "kubernetes_secret" "database_secret_name" {
  for_each = toset(local.drupal_databases_keys)

  metadata {
    name        = local.map_of_drupal_databases[each.key].helm_release_name == null ? "drupal-${local.map_of_drupal_databases[each.key].release_branch_name}-${local.map_of_drupal_databases[each.key].project_id}-db-user" : "${local.map_of_drupal_databases[each.key].helm_release_name}-db-user"
    namespace   = var.use_existing_kubernetes_namespaces ? local.map_of_drupal_databases[each.key].namespace : kubernetes_namespace.namespace[local.map_of_drupal_databases[each.key].namespace].metadata[0].name
    annotations = {}
    labels      = var.default_k8s_labels
  }
  data = {
    endpoint = local.map_of_drupal_databases[each.key].host != null ? local.map_of_drupal_databases[each.key].host : ""
    port     = local.map_of_drupal_databases[each.key].port
    database = local.map_of_output_drupal_databases[each.key].database
    username = local.map_of_output_drupal_databases[each.key].user
    password = local.map_of_output_drupal_databases[each.key].password
  }
}
