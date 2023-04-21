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
  }
```

The module will create a bucket, a database and a user for each project and as
output will return the application credentials for each resource.

```sh
terraform output drupal_apps_database_credentials
terraform output drupal_apps_bucket_credentials
terraform output helm_values_for_databases
terraform output helm_values_for_buckets
```

If you need to import an existing bucket or database/user, you can specify the
`bucket_name`, `database_name` and `database_user_name`. You also need to disable
the random suffix `bucket_append_random_suffix` for the bucket name.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.19 |
| <a name="provider_template"></a> [template](#provider\_template) | >= 2.2.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.47.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.19 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.2.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudsql_instance_name"></a> [cloudsql\_instance\_name](#input\_cloudsql\_instance\_name) | The name of the existing Google CloudSQL Instance name. Actually only a MySQL 5.7 or 8 instance is supported. | `string` | `""` | no |
| <a name="input_cloudsql_privileged_user_name"></a> [cloudsql\_privileged\_user\_name](#input\_cloudsql\_privileged\_user\_name) | The name of the privileged user of the Cloud SQL instance | `string` | `""` | no |
| <a name="input_cloudsql_privileged_user_password"></a> [cloudsql\_privileged\_user\_password](#input\_cloudsql\_privileged\_user\_password) | The password of the privileged user of the Cloud SQL instance | `string` | `""` | no |
| <a name="input_create_buckets"></a> [create\_buckets](#input\_create\_buckets) | If true, the module will create a bucket for each project. | `bool` | `true` | no |
| <a name="input_create_databases_and_users"></a> [create\_databases\_and\_users](#input\_create\_databases\_and\_users) | If true, the module will create a user and a database for each project. | `bool` | `true` | no |
| <a name="input_drupal_projects_list"></a> [drupal\_projects\_list](#input\_drupal\_projects\_list) | The list of Drupal projects, add a project name and this will create all infrastructure resources needed to run your project (bucket, database, user with relative credentials). Database resources are created in the CloudSQL instance you specified. Please not that you can assign only a database to a single user, the same user cannot be assigned to multiple databases. The default values are thought for a production environment, they will need to be adjusted accordingly for a stage environment. | <pre>list(object({<br>    project_name                    = string # The name of the project, it will be used to create the bucket name, the database name and the database user name, will usually match the project gitlab path, but in case of long nomenclature or multi-site project it might be different.<br>    gitlab_project_id               = number<br>    release_branch_name             = optional(string, "main") # It is the name of the release branch and is used for naming all resources (namespaces, buckets, databases, etc.)<br>    kubernetes_namespace            = optional(string, null)   # By default it is built as <project_name>-<gitlab_project_id>-<release_branch_name> and is always created.<br>    helm_release_name               = optional(string, null)   # By default it corresponds to the Drupal PKG release that corresponds to drupal-${CI_COMMIT_REF_SLUG}-${CI_PROJECT_ID} and is used for the name of secrets.<br>    database_name                   = optional(string, null)<br>    database_user_name              = optional(string, null)<br>    database_host                   = optional(string, null)<br>    database_port                   = optional(number, 3306)<br>    bucket_name                     = optional(string, null)<br>    bucket_host                     = optional(string, "storage.googleapis.com")<br>    bucket_append_random_suffix     = optional(bool, true)<br>    bucket_location                 = optional(string, null)<br>    bucket_storage_class            = optional(string, "STANDARD") # https://cloud.google.com/storage/docs/storage-classes<br>    bucket_enable_versioning        = optional(bool, true)<br>    bucket_enable_disaster_recovery = optional(bool, true)<br>    bucket_force_destroy            = optional(bool, false)<br>  }))</pre> | n/a | yes |
| <a name="input_logging_bucket_name"></a> [logging\_bucket\_name](#input\_logging\_bucket\_name) | The name of the logging bucket. If empty, no logging bucket will be added and bucket logs will be disabled. | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region in which the resources belongs. | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_drupal_apps_bucket_credentials"></a> [drupal\_apps\_bucket\_credentials](#output\_drupal\_apps\_bucket\_credentials) | Drupal apps bucket credentials for each Drupal project. |
| <a name="output_drupal_apps_database_credentials"></a> [drupal\_apps\_database\_credentials](#output\_drupal\_apps\_database\_credentials) | Drupal apps database credentials for each Drupal project. |
| <a name="output_drupal_apps_helm_values_for_buckets"></a> [drupal\_apps\_helm\_values\_for\_buckets](#output\_drupal\_apps\_helm\_values\_for\_buckets) | n/a |
| <a name="output_drupal_apps_helm_values_for_databases"></a> [drupal\_apps\_helm\_values\_for\_databases](#output\_drupal\_apps\_helm\_values\_for\_databases) | n/a |
## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.bucket_secret_name](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.database_secret_name](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [template_file.helm_values_for_buckets](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.helm_values_for_databases](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_drupal_buckets"></a> [drupal\_buckets](#module\_drupal\_buckets) | github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper | 9f41eeb |
| <a name="module_drupal_databases_and_users"></a> [drupal\_databases\_and\_users](#module\_drupal\_databases\_and\_users) | github.com/sparkfabrik/terraform-google-gcp-mysql-db-and-user-creation-helper | c30924e |

<!-- END_TF_DOCS -->

```

```
