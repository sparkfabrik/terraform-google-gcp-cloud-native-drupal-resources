locals {
  map_of_drupal_buckets = var.create_buckets == true ? {
    for o in local.drupal_buckets_list : o.name => o
  } : {}
  map_of_drupal_databases = trimspace(var.cloudsql_instance_name) != "" && trimspace(var.cloudsql_privileged_user_name) != "" && trimspace(var.cloudsql_privileged_user_password) != "" && var.create_databases_and_users == true ? {
    for o in local.drupal_database_and_user_list : o.database => o
  } : {}
  map_of_output_drupal_databases = trimspace(var.cloudsql_instance_name) != "" && trimspace(var.cloudsql_privileged_user_name) != "" && trimspace(var.cloudsql_privileged_user_password) != "" && var.create_databases_and_users == true ? {
    for o in module.drupal_databases_and_users[0].sql_users_creds : o.database => o
  } : {}
  map_of_drupal_redis = {
    for k, v in {
      for o in local.drupal_redis_list :
      "${o.namespace}-${o.helm_release_name != null ? "${o.helm_release_name}-redis" : "drupal-${o.release_branch_name}-${o.project_id}-redis"}" => {
        namespace   = o.namespace
        host        = o.host
        port        = o.port
        secret_name = (o.helm_release_name != null ? "${o.helm_release_name}-redis" : "drupal-${o.release_branch_name}-${o.project_id}-redis")
      }...
      if trimspace(o.host) != "" && o.port != null
    } : k => v[0]
  }
}

resource "kubernetes_secret" "bucket_secret_name" {
  for_each = {
    for o in local.map_of_drupal_buckets : o.name => o
    if var.create_buckets == true
  }

  metadata {
    # If not specified, we suppose that the Helm release name is defined with
    # the following convention (the default of sparkfabrik/pkg_drupal):
    # PKG_DRUPAL_HELM_RELEASE_NAME: drupal-${CI_COMMIT_REF_SLUG}-${CI_PROJECT_ID}
    name        = each.value.helm_release_name == null ? "drupal-${each.value.release_branch_name}-${each.value.project_id}-bucket" : "${each.value.helm_release_name}-bucket"
    namespace   = var.use_existing_kubernetes_namespaces ? each.value.namespace : kubernetes_namespace.namespace[each.value.namespace].metadata[0].name
    annotations = {}
    labels      = var.default_k8s_labels
  }
  data = {
    "endpoint"         = each.value.host
    "name"             = module.drupal_buckets[0].buckets_access_credentials[each.key].bucket_name
    "username"         = module.drupal_buckets[0].buckets_access_credentials[each.key].access_id
    "password"         = module.drupal_buckets[0].buckets_access_credentials[each.key].secret
    "nginx_osb_bucket" = "https://${each.value.host}/${module.drupal_buckets[0].buckets_access_credentials[each.key].bucket_name}${each.value.legacy_public_files_path}"
  }
}

resource "kubernetes_secret" "database_secret_name" {
  for_each = {
    for o in local.map_of_drupal_databases : o.database => o
    if trimspace(o.namespace) != "" && var.create_databases_and_users == true
  }
  metadata {
    # If not specified, we suppose that the Helm release name is defined with
    # the following convention (the default of sparkfabrik/pkg_drupal):
    # PKG_DRUPAL_HELM_RELEASE_NAME: drupal-${CI_COMMIT_REF_SLUG}-${CI_PROJECT_ID}
    name        = each.value.helm_release_name == null ? "drupal-${each.value.release_branch_name}-${each.value.project_id}-db-user" : "${each.value.helm_release_name}-db-user"
    namespace   = var.use_existing_kubernetes_namespaces ? each.value.namespace : kubernetes_namespace.namespace[each.value.namespace].metadata[0].name
    annotations = {}
    labels      = var.default_k8s_labels
  }
  data = {
    "endpoint" = each.value.host != null ? each.value.host : ""
    "port"     = each.value.port
    "database" = local.map_of_output_drupal_databases[each.key].database
    "username" = local.map_of_output_drupal_databases[each.key].user
    "password" = local.map_of_output_drupal_databases[each.key].password
  }
}

resource "kubernetes_secret_v1" "redis" {
  for_each = local.map_of_drupal_redis
  metadata {
    name        = each.value.secret_name
    namespace   = var.use_existing_kubernetes_namespaces ? each.value.namespace : kubernetes_namespace.namespace[each.value.namespace].metadata[0].name
    annotations = {}
    labels      = var.default_k8s_labels
  }
  data = {
    "host" = each.value.host
    "port" = each.value.port
  }
}
