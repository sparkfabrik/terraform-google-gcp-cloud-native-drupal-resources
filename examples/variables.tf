variable "project_id" {
  type    = string
  default = "my-project"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "drupal_projects_list" {
  description = "The list of Drupal projects, add a project name and this will create all infrastructure resources needed to run your project (bucket, database, user with relative credentials). Database resources are created in the production CloudSQL instance. Please not that you can assign only a database to a single user, the same user cannot be assigned to multiple databases."
  type = list(object({
    project_name                    = string
    bucket_append_random_suffix     = optional(bool, true)
    bucket_location                 = optional(string, null)
    bucket_storage_class            = optional(string, "STANDARD")
    bucket_enable_versioning        = optional(bool, true)
    bucket_enable_disaster_recovery = optional(bool, true)
  }))
  default = []
}
