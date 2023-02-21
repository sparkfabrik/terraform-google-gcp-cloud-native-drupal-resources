# Terraform module for creating infrastructure resources needed to a cloud native Drupal on GCP. 

This module creates the resources needed to deploy a **Cloud Native Drupal** instance 
on **Google Cloud Platform**.

Prerequisites are a GCP project in which a MySQL CloudSQL instance exists,
with administrator credentials needed to create the databases and users on the 
instance itself.

The module uses two sub-modules ([gcp-application-bucket-creation-helper
](https://registry.terraform.io/modules/sparkfabrik/gcp-application-bucket-creation-helper/google/latest) 
and [gcp-mysql-db-and-user-creation-helper](https://registry.terraform.io/modules/sparkfabrik/gcp-mysql-db-and-user-creation-helper/google/latest))
that take care of database/user creation and bucket creation. The names and
characteristics of the resources created are highly opinionated and configured for
a Drupal project.
In the event that it is necessary to create resources for a different non Drupal 
application, it is recommended to use and configure the individual modules.

The module accept a list of objects as input, each object represents a Drupal 
project and resource configuration. **The only required field is the `project_name`**,
used to name all resources.

```terraform
  {
    project_name                    = string
    database_name                   = optional(string, null)
    database_user_name              = optional(string, null)
    bucket_name                     = optional(string, null)
    bucket_append_random_suffix     = optional(bool, true)
    bucket_location                 = optional(string, null)
    bucket_storage_class            = optional(string, "STANDARD")
    bucket_enable_versioning        = optional(bool, true)
    bucket_enable_disaster_recovery = optional(bool, true)
  }
```

The module will create a bucket, a database and a user for each project and as
output will return the application credentials for each resource.

```sh
terraform output drupal_apps_database_credentials
terraform output drupal_apps_bucket_credentials
```

If you need to import an existing bucket or database/user, you can specify the
`bucket_name`, `database_name` and `database_user_name`. You also need to disable
the random suffix `bucket_append_random_suffix` for the bucket name.

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.47.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudsql_instance_name"></a> [cloudsql\_instance\_name](#input\_cloudsql\_instance\_name) | The name of the existing Google CloudSQL Instance name. Actually only a MySQL 5.7 or 8 instance is supported. | `string` | n/a | yes |
| <a name="input_cloudsql_privileged_user_name"></a> [cloudsql\_privileged\_user\_name](#input\_cloudsql\_privileged\_user\_name) | The name of the privileged user of the Cloud SQL instance | `string` | n/a | yes |
| <a name="input_cloudsql_privileged_user_password"></a> [cloudsql\_privileged\_user\_password](#input\_cloudsql\_privileged\_user\_password) | The password of the privileged user of the Cloud SQL instance | `string` | n/a | yes |
| <a name="input_drupal_projects_list"></a> [drupal\_projects\_list](#input\_drupal\_projects\_list) | The list of Drupal projects, add a project name and this will create all infrastructure resources needed to run your project (bucket, database, user with relative credentials). Database resources are created in the CloudSQL instance you specified. Please not that you can assign only a database to a single user, the same user cannot be assigned to multiple databases. | <pre>list(object({<br>    project_name                    = string<br>    database_name                   = optional(string, null)<br>    database_user_name              = optional(string, null)<br>    bucket_name                     = optional(string, null)<br>    bucket_append_random_suffix     = optional(bool, true)<br>    bucket_location                 = optional(string, null)<br>    bucket_storage_class            = optional(string, "STANDARD")<br>    bucket_enable_versioning        = optional(bool, true)<br>    bucket_enable_disaster_recovery = optional(bool, true)<br>  }))</pre> | n/a | yes |
| <a name="input_logging_bucket_name"></a> [logging\_bucket\_name](#input\_logging\_bucket\_name) | The name of the logging bucket. If empty, no logging bucket will be added and bucket logs will be disabled. | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region in which the resources belongs. | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_drupal_apps_bucket_credentials"></a> [drupal\_apps\_bucket\_credentials](#output\_drupal\_apps\_bucket\_credentials) | Drupal apps bucket credentials for each Drupal project. |
| <a name="output_drupal_apps_database_credentials"></a> [drupal\_apps\_database\_credentials](#output\_drupal\_apps\_database\_credentials) | Drupal apps database credentials for each Drupal project. |
## Resources

No resources.
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_drupal_buckets"></a> [drupal\_buckets](#module\_drupal\_buckets) | sparkfabrik/gcp-application-bucket-creation-helper/google | >= 0.1.0 |
| <a name="module_drupal_databases_and_users"></a> [drupal\_databases\_and\_users](#module\_drupal\_databases\_and\_users) | sparkfabrik/gcp-mysql-db-and-user-creation-helper/google | >= 0.3 |

<!-- END_TF_DOCS -->
