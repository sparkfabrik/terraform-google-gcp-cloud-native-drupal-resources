variable "project_id" {
  type        = string
  description = "The ID of the project in which the resource belongs."
}

variable "region" {
  type        = string
  description = "The region in which the resources belongs."
}

variable "cloudsql_instance_name" {
  type        = string
  description = "The name of the existing Google CloudSQL Instance name. Actually only a MySQL 5.7 or 8 instance is supported."
  default     = ""
}

variable "cloudsql_privileged_user_name" {
  type        = string
  description = "The name of the privileged user of the Cloud SQL instance"
  default     = ""
}

variable "cloudsql_privileged_user_password" {
  type        = string
  description = "The password of the privileged user of the Cloud SQL instance"
  default     = ""
}

variable "logging_bucket_name" {
  type        = string
  description = "The name of the logging bucket. If empty, no logging bucket will be added and bucket logs will be disabled."
  default     = ""
}

variable "global_tags" {
  description = "A list of tags to be applied to all the drupal buckets, in the form <TAG_KEY_SHORTNAME>/<TAG_VALUE_SHORTNAME>. If a resource specify a list of tags, the global tags will be overridden and replaced by those specified in the resource. Please note that actually only the buckets are tagged by this module."
  type        = list(string)
  default     = []
}

variable "default_k8s_labels" {
  description = "A map of labels to be applied to all the kubernetes resources created by this module. If a resource specify a map of labels, the default labels will merged with those specified in the resource."
  type        = map(string)
  default = {
    "managed-by" = "terraform"
  }
}

variable "drupal_projects_list" {
  description = "The list of Drupal projects, add a project name and this will create all infrastructure resources needed to run your project (bucket, database, user with relative credentials). Database resources are created in the CloudSQL instance you specified. Please not that you can assign only a database to a single user, the same user cannot be assigned to multiple databases. The default values are thought for a production environment, they will need to be adjusted accordingly for a stage environment."
  type = list(object({
    project_name                         = string
    gitlab_project_id                    = number
    release_branch_name                  = optional(string, "main")
    kubernetes_namespace                 = optional(string, null)
    kubernetes_namespace_labels          = optional(map(string), {})
    helm_release_name                    = optional(string, null)
    database_name                        = optional(string, null)
    database_user_name                   = optional(string, null)
    database_host                        = optional(string, null)
    database_port                        = optional(number, 3306)
    bucket_name                          = optional(string, null)
    bucket_host                          = optional(string, "storage.googleapis.com")
    bucket_append_random_suffix          = optional(bool, true)
    bucket_location                      = optional(string, null)
    bucket_storage_class                 = optional(string, "STANDARD")
    bucket_enable_versioning             = optional(bool, true)
    bucket_enable_disaster_recovery      = optional(bool, true)
    bucket_force_destroy                 = optional(bool, false)
    bucket_legacy_public_files_path      = optional(string, "/public")
    bucket_set_all_users_as_viewer       = optional(bool, false)
    bucket_labels                        = optional(map(string), {})
    bucket_tag_list                      = optional(list(string), [])
    bucket_obj_adm                       = optional(list(string), [])
    bucket_obj_vwr                       = optional(list(string), [])
    bucket_soft_delete_retention_seconds = optional(number, 0)
    network_policy                       = optional(string, "")
  }))

  validation {
    # project_name must:
    # - start with a lowercase letter or a number
    # - contain only lowercase letters, numbers, hyphens and underscores
    # and be:
    # - 6 to 16 characters long if database_host is not null meaning that the database will be created from the module
    # - 6 to 23 characters long if database_host, database_name, database_user_name are not null meaning that database name and user name are passed to the module
    # - 6 to 23 characters long if database_host is null meaning that no database will be created from the module
    condition = alltrue([
      for p in var.drupal_projects_list :
      (can(regex("^[0-9a-z][0-9a-z_-]{4,21}[0-9a-z]$", p.project_name)) && length(p.project_name) > 5) &&
      (
        (p.database_host != null && p.database_name == null && p.database_user_name == null && length(p.project_name) <= 16) ||
        (p.database_host != null && p.database_name != null && p.database_user_name != null && length(p.project_name) <= 23) ||
        (p.database_host == null && length(p.project_name) <= 23)
      ) &&
      (
        (p.network_policy != "" && contains(["isolated", "restricted"], p.network_policy)) ||
        (p.network_policy == "")
      )
    ])
    error_message = "The project name is invalid. Must be 6 to 16 characters long, with only lowercase letters, numbers, hyphens and underscores if the database must be created by the module or 6 to 23 characters long if we pass database_host database_user_name and database_name to the module. If a network policy is specified, it must be 'isolated' or 'restricted'."
  }

  validation {
    condition = alltrue([
      for p in var.drupal_projects_list :
      (can(regex("^[0-9a-z_-]{6,32}$", p.database_user_name))) || p.database_user_name == null
    ])
    error_message = "The database user name is invalid. Must be 6 to 32 characters long, with only lowercase letters, numbers, hyphens and underscores."
  }
}

variable "create_buckets" {
  type        = bool
  description = "If true, the module will create a bucket for each project."
  default     = true
}

variable "create_databases_and_users" {
  type        = bool
  description = "If true, the module will create a user and a database for each project."
  default     = true
}

variable "use_existing_kubernetes_namespaces" {
  type        = bool
  description = "If false, the module will create the various namespaces for Kubernetes resources (secrets). Set to true to prevent at a global level the namespaces creation, useful if the namespaces have been created outside of Terraform, for example, by the Helm release during the deploy of the application or in other ways."
  default     = false
}

variable "bucket_disaster_recovery_location" {
  type        = string
  description = "The location in which the disaster recovery bucket will be created. For a list of available regions, see https://cloud.google.com/storage/docs/locations. By default, the disaster recovery bucket will be created in the same location as the primary bucket."
  default     = ""
}

variable "create_clousql_dumps_bucket" {
  type        = bool
  description = "If true, the module will create a Google Storage bucket that can be used as a destination for CloudSQL dumps. The bucket will also be tagged with the global tags."
  default     = false
}
