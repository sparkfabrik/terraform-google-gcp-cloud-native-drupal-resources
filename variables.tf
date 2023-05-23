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

variable "drupal_projects_list" {
  description = "The list of Drupal projects, add a project name and this will create all infrastructure resources needed to run your project (bucket, database, user with relative credentials). Database resources are created in the CloudSQL instance you specified. Please not that you can assign only a database to a single user, the same user cannot be assigned to multiple databases. The default values are thought for a production environment, they will need to be adjusted accordingly for a stage environment."
  type = list(object({
    project_name                    = string # The name of the project, it will be used to create the bucket name, the database name and the database user name, will usually match the project gitlab path, but in case of long nomenclature or multi-site project it might be different.
    gitlab_project_id               = number
    release_branch_name             = optional(string, "main") # It is the name of the release branch and is used for naming all resources (namespaces, buckets, databases, etc.)
    kubernetes_namespace            = optional(string, null)   # By default it is built as <project_name>-<gitlab_project_id>-<release_branch_name> and is always created.
    helm_release_name               = optional(string, null)   # By default it corresponds to the Drupal PKG release that corresponds to drupal-${CI_COMMIT_REF_SLUG}-${CI_PROJECT_ID} and is used for the name of secrets.
    database_name                   = optional(string, null)
    database_user_name              = optional(string, null)
    database_host                   = optional(string, null)
    database_port                   = optional(number, 3306)
    bucket_name                     = optional(string, null)
    bucket_host                     = optional(string, "storage.googleapis.com")
    bucket_append_random_suffix     = optional(bool, true)
    bucket_location                 = optional(string, null)
    bucket_storage_class            = optional(string, "STANDARD") # https://cloud.google.com/storage/docs/storage-classes
    bucket_enable_versioning        = optional(bool, true)
    bucket_enable_disaster_recovery = optional(bool, true)
    bucket_force_destroy            = optional(bool, false)
  }))

  validation {
    # The project name must contain only lower caps letters and "-" and "_" and be between 6 and 23 characters long, since the database user name must be less than 32 chars and we append "_drupal_u" to the project name.
    condition = alltrue([
      for p in var.drupal_projects_list :
      can(regex("^[0-9a-z_-]{6,23}$", p.project_name))
    ])
    error_message = "The name of the Drupal project should be between 6 and 23 characters long and contains only numbers, lower caps letters and \"_-\"."
  }

  validation {
    # The project name must contain only lower caps letters and "-" and "_" and be between 6 and 20 characters long, since the database user name must be less than 32 chars and we append "_drupal_user" to the project name.
    condition = alltrue([
      for p in var.drupal_projects_list :
      can(regex("^[0-9a-z]{1}[0-9a-z_-]+[0-9a-z]{1}$", p.project_name))
    ])
    error_message = "The name of the Drupal project can start and end only with a lower caps letters or numbers."
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

variable "bucket_disaster_recovery_location" {
  type        = string
  description = "The location in which the disaster recovery bucket will be created. For a list of available regions, see https://cloud.google.com/storage/docs/locations. By default, the disaster recovery bucket will be created in the same location as the primary bucket."
  default     = ""
}
