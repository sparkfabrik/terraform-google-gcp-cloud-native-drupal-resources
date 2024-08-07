# Terraform module for creating infrastructure resources needed to a cloud native Drupal on GCP

This module creates the resources needed to deploy a **Cloud Native Drupal** instance
on **Google Cloud Platform**.

Prerequisites are a GCP project in which a MySQL CloudSQL instance exists,
with administrator credentials needed to create the databases and users on the
instance itself.

The module uses two sub-modules ([gcp-application-bucket-creation-helper](https://registry.terraform.io/modules/sparkfabrik/gcp-application-bucket-creation-helper/google/latest)
and [gcp-mysql-db-and-user-creation-helper](https://registry.terraform.io/modules/sparkfabrik/gcp-mysql-db-and-user-creation-helper/google/latest))
that take care of database/user creation and bucket creation. The names and
characteristics of the resources created are highly opinionated and configured for
a Drupal project.
In the event that it is necessary to create resources for a different non Drupal
application, it is recommended to use and configure the individual modules.

The module accept a list of objects as input, each object represents a Drupal
project and resource configuration.

**The required fields for each project object** are the `project_name`, the `gitlab_project_id`
used to name all resources; the `database_host` field is also mandatory if we want to create
the secrets for the database resources.

The variable structure is the following:

```terraform
  {
    # The name of the project, it will be used to create the bucket name, the database name and the database user name,
    # will usually match the project gitlab path, but in case of long nomenclature or multi-site project it might be
    # different.
    project_name                    = string
    # The ID of the Drupal project in Gitlab, it is useful to identify the project the resources belong to.
    gitlab_project_id               = number
    # It is the name of the release branch and is used for naming all resources (namespaces, buckets, databases, etc.)
    release_branch_name             = optional(string, "main")
    # If not specified, the kubernetes_namespace by default it is built as
    # <project_name>-<gitlab_project_id>-<release_branch_name>.
    kubernetes_namespace            = optional(string, null)
    # By default it corresponds to the Drupal PKG release that corresponds to
    # drupal-${CI_COMMIT_REF_SLUG}-${CI_PROJECT_ID} and is used for the name of secrets.
    helm_release_name               = optional(string, null)
    # By default the name is <project_name>_<gitlab_project_id>_<release_branch_name>_dp, where dp stands for Drupal.
    database_name                   = optional(string, null)
    # By default the name is <project_name>_<gitlab_project_id>_<release_branch_name>_dp_u, where dp_u stands
    # for Drupal user.
    database_user_name              = optional(string, null)
    # The IP of the CloudSQL instance, it's mandatory to create the secret with credentials to connect to the database.
    database_host                   = optional(string, null)
    # The port of the CloudSQL instance, default to 3306.
    database_port                   = optional(number, 3306)
    # The name of the bucket, by default it is built as <project_name>-<gitlab_project_id>-<release_branch_name>.
    bucket_name                     = optional(string, null)
    # The host of the bucket, by default for Google buckets it is storage.googleapis.com.
    bucket_host                     = optional(string, "storage.googleapis.com")
    # True by default, and is used to prevent name collision for created resources.
    bucket_append_random_suffix     = optional(bool, true)
    # The location of the bucket, by default it is the same as the project region.
    bucket_location                 = optional(string, null)
    # The storage class of the bucket (https://cloud.google.com/storage/docs/storage-classes), by default it is STANDARD.
    bucket_storage_class            = optional(string, "STANDARD")
    # The versioning of the bucket, by default it is enabled.
    bucket_enable_versioning        = optional(bool, true)
    # Here you can choose to enable or disable the disaster recovery bucket, by default it is enabled. You can disable it
    # for example for test or development environments.
    bucket_enable_disaster_recovery = optional(bool, true)
    # Set to true to enable the force destroy of the bucket, by default it is false. If true, the bucket and all its objects
    # will be deleted when the terraform resource is removed.
    bucket_force_destroy            = optional(bool, false)
    # Here you can customize the path of public files inside the drupal bucket. This values are used to create
    # the secrets for the application.
    bucket_legacy_public_files_path = optional(string, "/public")
    # The property `set_all_users_as_viewer` controls if the bucket content will be globally readable by anonymous users
    # (default false).
    bucket_set_all_users_as_viewer  = optional(bool, false)
    # Here you can also pass a map of key/value label pairs to assign to the bucket, i.e. `{ env = "stage", app = "mysite" }`.
    bucket_labels                   = optional(map(string), {})
    # You can also pass a list of tags values written in the user friendly name <TAG_KEY_SHORTNAME>/<TAG_VALUE_SHORTNAME>, 
    # i.e. `["dev/editor","ops/admin"]`) to bind to the buckets using the `tag_list` property. The tags must exist in 
    # the google project, otherwise the module will fail.
    bucket_tag_list                 = optional(list(string), [])
    # Properties bucket_obj_vwr and bucket_obj_adm set a list of specific IAM members as objectViewers and objectAdmin
    bucket_obj_adm                  = optional(list(string), [])
    bucket_obj_vwr                  = optional(list(string), [])
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
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.47.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.19 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.2 |
| <a name="provider_template"></a> [template](#provider\_template) | >= 2.2.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.47.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.19 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.2 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.2.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_disaster_recovery_location"></a> [bucket\_disaster\_recovery\_location](#input\_bucket\_disaster\_recovery\_location) | The location in which the disaster recovery bucket will be created. For a list of available regions, see https://cloud.google.com/storage/docs/locations. By default, the disaster recovery bucket will be created in the same location as the primary bucket. | `string` | `""` | no |
| <a name="input_cloudsql_instance_name"></a> [cloudsql\_instance\_name](#input\_cloudsql\_instance\_name) | The name of the existing Google CloudSQL Instance name. Actually only a MySQL 5.7 or 8 instance is supported. | `string` | `""` | no |
| <a name="input_cloudsql_privileged_user_name"></a> [cloudsql\_privileged\_user\_name](#input\_cloudsql\_privileged\_user\_name) | The name of the privileged user of the Cloud SQL instance | `string` | `""` | no |
| <a name="input_cloudsql_privileged_user_password"></a> [cloudsql\_privileged\_user\_password](#input\_cloudsql\_privileged\_user\_password) | The password of the privileged user of the Cloud SQL instance | `string` | `""` | no |
| <a name="input_create_buckets"></a> [create\_buckets](#input\_create\_buckets) | If true, the module will create a bucket for each project. | `bool` | `true` | no |
| <a name="input_create_clousql_dumps_bucket"></a> [create\_clousql\_dumps\_bucket](#input\_create\_clousql\_dumps\_bucket) | If true, the module will create a Google Storage bucket that can be used as a destination for CloudSQL dumps. The bucket will also be tagged with the global tags. | `bool` | `false` | no |
| <a name="input_create_databases_and_users"></a> [create\_databases\_and\_users](#input\_create\_databases\_and\_users) | If true, the module will create a user and a database for each project. | `bool` | `true` | no |
| <a name="input_drupal_projects_list"></a> [drupal\_projects\_list](#input\_drupal\_projects\_list) | The list of Drupal projects, add a project name and this will create all infrastructure resources needed to run your project (bucket, database, user with relative credentials). Database resources are created in the CloudSQL instance you specified. Please not that you can assign only a database to a single user, the same user cannot be assigned to multiple databases. The default values are thought for a production environment, they will need to be adjusted accordingly for a stage environment. | <pre>list(object({<br>    project_name                    = string<br>    gitlab_project_id               = number<br>    release_branch_name             = optional(string, "main")<br>    kubernetes_namespace            = optional(string, null)<br>    helm_release_name               = optional(string, null)<br>    database_name                   = optional(string, null)<br>    database_user_name              = optional(string, null)<br>    database_host                   = optional(string, null)<br>    database_port                   = optional(number, 3306)<br>    bucket_name                     = optional(string, null)<br>    bucket_host                     = optional(string, "storage.googleapis.com")<br>    bucket_append_random_suffix     = optional(bool, true)<br>    bucket_location                 = optional(string, null)<br>    bucket_storage_class            = optional(string, "STANDARD")<br>    bucket_enable_versioning        = optional(bool, true)<br>    bucket_enable_disaster_recovery = optional(bool, true)<br>    bucket_force_destroy            = optional(bool, false)<br>    bucket_legacy_public_files_path = optional(string, "/public")<br>    bucket_set_all_users_as_viewer  = optional(bool, false)<br>    bucket_labels                   = optional(map(string), {})<br>    bucket_tag_list                 = optional(list(string), [])<br>    bucket_obj_adm                  = optional(list(string), [])<br>    bucket_obj_vwr                  = optional(list(string), [])<br>  }))</pre> | n/a | yes |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | A list of tags to be applied to all the drupal buckets, in the form <TAG\_KEY\_SHORTNAME>/<TAG\_VALUE\_SHORTNAME>. If a resource specify a list of tags, the global tags will be overridden and replaced by those specified in the resource. Please note that actually only the buckets are tagged by this module. | `list(string)` | `[]` | no |
| <a name="input_logging_bucket_name"></a> [logging\_bucket\_name](#input\_logging\_bucket\_name) | The name of the logging bucket. If empty, no logging bucket will be added and bucket logs will be disabled. | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region in which the resources belongs. | `string` | n/a | yes |
| <a name="input_use_existing_kubernetes_namespaces"></a> [use\_existing\_kubernetes\_namespaces](#input\_use\_existing\_kubernetes\_namespaces) | If false, the module will create the various namespaces for Kubernetes resources (secrets). Set to true to prevent at a global level the namespaces creation, useful if the namespaces have been created outside of Terraform, for example, by the Helm release during the deploy of the application or in other ways. | `bool` | `false` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_details_of_used_tag_keys"></a> [details\_of\_used\_tag\_keys](#output\_details\_of\_used\_tag\_keys) | Details of the tag keys passed to this module. |
| <a name="output_details_of_used_tag_values"></a> [details\_of\_used\_tag\_values](#output\_details\_of\_used\_tag\_values) | Details of the tag values passed to this module. |
| <a name="output_drupal_apps_bucket_credentials"></a> [drupal\_apps\_bucket\_credentials](#output\_drupal\_apps\_bucket\_credentials) | Drupal apps bucket credentials for each Drupal project. |
| <a name="output_drupal_apps_database_credentials"></a> [drupal\_apps\_database\_credentials](#output\_drupal\_apps\_database\_credentials) | Drupal apps database credentials for each Drupal project. |
| <a name="output_drupal_apps_helm_values_for_buckets"></a> [drupal\_apps\_helm\_values\_for\_buckets](#output\_drupal\_apps\_helm\_values\_for\_buckets) | Output helm values to be used for buckets for each Drupal project. |
| <a name="output_drupal_apps_helm_values_for_databases"></a> [drupal\_apps\_helm\_values\_for\_databases](#output\_drupal\_apps\_helm\_values\_for\_databases) | Output helm values to be used for databases for each Drupal project. |
## Resources

| Name | Type |
|------|------|
| [google_storage_bucket.cloudsql_dumps](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.cloudsql_dumps_bucket_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_tags_location_tag_binding.binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_location_tag_binding) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.bucket_secret_name](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.database_secret_name](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_id.cloudsql_dumps_bucket_name_suffix](https://registry.terraform.io/providers/hashicorp/random/3.6.2/docs/resources/id) | resource |
| [google_sql_database_instance.cloudsql_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/sql_database_instance) | data source |
| [google_tags_tag_key.tag_keys](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/tags_tag_key) | data source |
| [google_tags_tag_value.tag_values](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/tags_tag_value) | data source |
| [template_file.helm_values_for_buckets](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.helm_values_for_databases](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_drupal_buckets"></a> [drupal\_buckets](#module\_drupal\_buckets) | github.com/sparkfabrik/terraform-google-gcp-application-bucket-creation-helper | 0.7.1 |
| <a name="module_drupal_databases_and_users"></a> [drupal\_databases\_and\_users](#module\_drupal\_databases\_and\_users) | github.com/sparkfabrik/terraform-google-gcp-mysql-db-and-user-creation-helper | 0.3.1 |

<!-- END_TF_DOCS -->
