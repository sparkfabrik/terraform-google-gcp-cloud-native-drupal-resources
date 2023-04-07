locals {
  module_drupal_buckets_is_empty = try(module.drupal_buckets, null) == null ? true : false
  map_of_drupal_buckets          = var.create_kubernetes_secrets_buckets == true && var.create_buckets == true ? { for o in local.drupal_buckets_list : o.name => o } : {}
  map_of_output_drupal_buckets   = var.create_kubernetes_secrets_buckets == true && var.create_buckets == true && !(local.module_drupal_buckets_is_empty) ? { for o in module.drupal_buckets.buckets_access_credentials : o.bucket_name => o } : {}
  map_of_drupal_database         = trimspace(var.cloudsql_instance_name) != "" && trimspace(var.cloudsql_privileged_user_name) != "" && trimspace(var.cloudsql_privileged_user_password) != "" && var.create_databases_and_users == true && var.create_kubernetes_secrets_databases_and_users == true ? { for o in local.drupal_database_and_user_list : o.database => o } : {}
  map_of_output_drupal_database  = trimspace(var.cloudsql_instance_name) != "" && trimspace(var.cloudsql_privileged_user_name) != "" && trimspace(var.cloudsql_privileged_user_password) != "" && var.create_databases_and_users == true && var.create_kubernetes_secrets_databases_and_users == true ? { for o in module.drupal_databases_and_users.sql_users_creds : o.database => o } : {}
}

resource "kubernetes_secret" "drupal_bucket_secret" {
  for_each = { for o in local.map_of_drupal_buckets : o.name => o
  if var.create_kubernetes_secrets_buckets == true && var.create_buckets == true }
  metadata {
    namespace = each.value.namespace
    name      = "drupal-${var.release_branch_name}-${var.gitlab_project_id}-bucket"
  }
  data = {
    "OSB_HOST"        = base64encode(each.value.host)
    "OSB_BUCKET_NAME" = base64encode(each.value.name)
    "OSB_ACCESS_KEY"  = base64encode(local.map_of_output_drupal_buckets[each.key].access_id)
    "OSB_SECRET_KEY"  = base64encode(local.map_of_output_drupal_buckets[each.key].secret)
  }
  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "kubernetes_secret" "drupal_database_secret" {
  for_each = { for o in local.map_of_drupal_database : o.database => o
  if var.create_kubernetes_secrets_databases_and_users == true }
  metadata {
    name      = "drupal-${var.release_branch_name}-${var.gitlab_project_id}-db-user"
    namespace = each.value.namespace
  }
  data = {
    "DB_HOST_0" = base64encode(each.value.host)
    "DB_NAME_0" = base64encode(each.value.database)
    "DB_USER_0" = base64encode(local.map_of_output_drupal_database[each.key].username)
    "DB_PASS_0" = base64encode(local.map_of_output_drupal_database[each.key].password)
  }
  depends_on = [
    kubernetes_namespace.namespace
  ]
}
