variable "my_project_id" {
  type    = string
  default = "my-project"
}

variable "my_region" {
  type    = string
  default = "europe-west1"
}

variable "my_drupal_projects_list" {
  description = "The list of Drupal projects, add a project name and this will create all infrastructure resources needed to run your project (bucket, database, user with relative credentials). Database resources are created in the CloudSQL instance you specified. Please not that you can assign only a database to a single user, the same user cannot be assigned to multiple databases. The default values are thought for a production environment, they will need to be adjusted accordingly for a stage environment."
  type = list(object({
    project_name                    = string
    gitlab_project_id               = number
    release_branch_name             = optional(string, "main")
    kubernetes_namespace            = optional(string, null)
    helm_release_name               = optional(string, null)
    database_name                   = optional(string, null)
    database_user_name              = optional(string, null)
    database_host                   = optional(string, null)
    database_port                   = optional(number, 3306)
    bucket_name                     = optional(string, null)
    bucket_host                     = optional(string, "storage.googleapis.com")
    bucket_append_random_suffix     = optional(bool, true)
    bucket_location                 = optional(string, null)
    bucket_storage_class            = optional(string, "STANDARD")
    bucket_enable_versioning        = optional(bool, true)
    bucket_enable_disaster_recovery = optional(bool, true)
    bucket_force_destroy            = optional(bool, false)
    bucket_legacy_public_files_path = optional(string, "/public")
    bucket_set_all_users_as_viewer  = optional(bool, false)
    bucket_labels                   = optional(map(string), {})
    bucket_tag_list                 = optional(list(string), [])
    bucket_obj_adm                  = optional(list(string), [])
    bucket_obj_vwr                  = optional(list(string), [])
  }))
  default = []
}
