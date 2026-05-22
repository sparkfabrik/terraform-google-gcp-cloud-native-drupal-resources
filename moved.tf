moved {
  from = kubernetes_namespace.namespace
  to   = kubernetes_namespace_v1.namespace
}

moved {
  from = kubernetes_secret.bucket_secret_name
  to   = kubernetes_secret_v1.bucket_secret_name
}

moved {
  from = kubernetes_secret.database_secret_name
  to   = kubernetes_secret_v1.database_secret_name
}
