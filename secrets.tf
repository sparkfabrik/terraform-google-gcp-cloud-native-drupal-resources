locals {
  map_of_drupal_buckets         = var.create_buckets == true ? { for o in local.drupal_buckets_list : o.name => o } : {}
  map_of_output_drupal_buckets  = var.create_buckets == true ? { for o in module.drupal_buckets[0].buckets_access_credentials : o.bucket_name => o } : {}
  map_of_drupal_database        = trimspace(var.cloudsql_instance_name) != "" && trimspace(var.cloudsql_privileged_user_name) != "" && trimspace(var.cloudsql_privileged_user_password) != "" && var.create_databases_and_users == true ? { for o in local.drupal_database_and_user_list : o.database => o } : {}
  map_of_output_drupal_database = trimspace(var.cloudsql_instance_name) != "" && trimspace(var.cloudsql_privileged_user_name) != "" && trimspace(var.cloudsql_privileged_user_password) != "" && var.create_databases_and_users == true ? { for o in module.drupal_databases_and_users[0].sql_users_creds : o.database => o } : {}
}

data "template_file" "helm_values_for_buckets" {
  for_each = { for o in local.map_of_drupal_buckets : o.name => o
  if var.create_buckets == true }

  template = file("${path.module}/files/template/helm_bucket.tpl")
  vars = {
    secret_bucket_name = kubernetes_secret.bucket_secret_name[each.key].metadata[0].name
  }
}

data "template_file" "helm_values_for_databases" {
  for_each = { for o in local.map_of_drupal_database : o.database => o
  if var.create_databases_and_users == true }

  template = file("${path.module}/files/template/helm_database.tpl")
  vars = {
    secret_database_name = kubernetes_secret.database_secret_name[each.key].metadata[0].name
  }
}

resource "kubernetes_secret" "bucket_secret_name" {
  for_each = { for o in local.map_of_drupal_buckets : o.name => o
  if var.create_buckets == true }

  metadata {
    namespace = each.value.namespace
    # PKG_DRUPAL_HELM_RELEASE_NAME: drupal-${CI_COMMIT_REF_SLUG}-${CI_PROJECT_ID}
    name = each.value.helm_release_name == null ? "drupal-${each.value.release_branch_name}-${each.value.project_id}-bucket" : "${each.value.helm_release_name}-bucket" # Helm release name PKG Drupal
  }
  data = {
    "endpoint" = base64encode(each.value.host)
    "name"     = base64encode(each.value.name)
    "username" = base64encode(local.map_of_output_drupal_buckets[each.key].access_id)
    "password" = base64encode(local.map_of_output_drupal_buckets[each.key].secret)
  }
  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "kubernetes_secret" "database_secret_name" {
  for_each = { for o in local.map_of_drupal_database : o.database => o
  if trimspace(o.namespace) != "" && var.create_databases_and_users == true }
  metadata {
    name      = each.value.helm_release_name == null ? "drupal-${each.value.release_branch_name}-${each.value.project_id}-db-user" : "${each.value.helm_release_name}-db-user" # Helm release name PKG Drupal
    namespace = each.value.namespace
  }
  data = {
    "endpoint" = base64encode(each.value.host)
    "database" = base64encode(each.value.database)
    "username" = base64encode(local.map_of_output_drupal_database[each.key].user)
    "password" = base64encode(local.map_of_output_drupal_database[each.key].password)
    "port"     = base64encode(each.value.port)
  }
  depends_on = [
    kubernetes_namespace.namespace
  ]
}
