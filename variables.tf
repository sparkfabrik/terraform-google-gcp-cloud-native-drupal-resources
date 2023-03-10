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
}

variable "cloudsql_privileged_user_name" {
  type        = string
  description = "The name of the privileged user of the Cloud SQL instance"
}

variable "cloudsql_privileged_user_password" {
  type        = string
  description = "The password of the privileged user of the Cloud SQL instance"
}

variable "logging_bucket_name" {
  type        = string
  description = "The name of the logging bucket. If empty, no logging bucket will be added and bucket logs will be disabled."
  default     = ""
}

variable "drupal_projects_list" {
  description = "The list of Drupal projects, add a project name and this will create all infrastructure resources needed to run your project (bucket, database, user with relative credentials). Database resources are created in the CloudSQL instance you specified. Please not that you can assign only a database to a single user, the same user cannot be assigned to multiple databases."
  type        = list(object({
    project_name                    = string
    database_name                   = optional(string, null)
    database_user_name              = optional(string, null)
    bucket_name                     = optional(string, null)
    bucket_append_random_suffix     = optional(bool, true)
    bucket_location                 = optional(string, null)
    bucket_storage_class            = optional(string, "STANDARD")
    bucket_enable_versioning        = optional(bool, true)
    bucket_enable_disaster_recovery = optional(bool, true)
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
