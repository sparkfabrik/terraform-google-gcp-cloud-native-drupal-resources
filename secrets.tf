locals {
  map_of_drupal_buckets         = var.create_buckets == true ? { for o in local.drupal_buckets_list : o.name => o } : {}
  map_of_drupal_database        = trimspace(var.cloudsql_instance_name) != "" && trimspace(var.cloudsql_privileged_user_name) != "" && trimspace(var.cloudsql_privileged_user_password) != "" && var.create_databases_and_users == true ? { for o in local.drupal_database_and_user_list : o.database => o } : {}
  map_of_output_drupal_database = trimspace(var.cloudsql_instance_name) != "" && trimspace(var.cloudsql_privileged_user_name) != "" && trimspace(var.cloudsql_privileged_user_password) != "" && var.create_databases_and_users == true ? { for o in module.drupal_databases_and_users[0].sql_users_creds : o.database => o } : {}
}

data "template_file" "helm_values_for_buckets" {
  for_each = { for o in local.map_of_drupal_buckets : o.name => o
  if var.create_buckets == true }

  template = templatefile("${path.module}/files/template/helm_bucket.tpl",
    {
      secret_bucket_name = kubernetes_secret.bucket_secret_name[each.key].metadata[0].name
    }
  )
}

data "template_file" "helm_values_for_databases" {
  for_each = { for o in local.map_of_drupal_database : o.database => o
  if var.create_databases_and_users == true }

  template = templatefile("${path.module}/files/template/helm_database.tpl",
    {
      secret_database_name = kubernetes_secret.database_secret_name[each.key].metadata[0].name
    }
  )
}

resource "kubernetes_secret" "bucket_secret_name" {
  for_each = { for o in local.map_of_drupal_buckets : o.name => o
  if var.create_buckets == true }

  metadata {
    # PKG_DRUPAL_HELM_RELEASE_NAME: drupal-${CI_COMMIT_REF_SLUG}-${CI_PROJECT_ID}
    name        = each.value.helm_release_name == null ? "drupal-${each.value.release_branch_name}-${each.value.project_id}-bucket" : "${each.value.helm_release_name}-bucket" # Helm release name PKG Drupal
    namespace   = each.value.namespace
    annotations = {}
    labels      = {}
  }
  data = {
    "endpoint" = each.value.host
    "name"     = each.value.name
    "username" = module.drupal_buckets[0].buckets_access_credentials[each.key].access_id
    "password" = module.drupal_buckets[0].buckets_access_credentials[each.key].secret
  }
  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "kubernetes_secret" "database_secret_name" {
  for_each = { for o in local.map_of_drupal_database : o.database => o
  if trimspace(o.namespace) != "" && var.create_databases_and_users == true }
  metadata {
    # PKG_DRUPAL_HELM_RELEASE_NAME: drupal-${CI_COMMIT_REF_SLUG}-${CI_PROJECT_ID}
    name        = each.value.helm_release_name == null ? "drupal-${each.value.release_branch_name}-${each.value.project_id}-db-user" : "${each.value.helm_release_name}-db-user" # Helm release name PKG Drupal
    namespace   = each.value.namespace
    annotations = {}
    labels      = {}
  }
  data = {
    "endpoint" = each.value.host
    "database" = each.value.database
    "username" = local.map_of_output_drupal_database[each.key].user
    "password" = local.map_of_output_drupal_database[each.key].password
    "port"     = each.value.port
  }
  depends_on = [
    kubernetes_namespace.namespace
  ]
}
