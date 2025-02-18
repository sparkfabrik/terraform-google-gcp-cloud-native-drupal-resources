# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.22.0] - 2025-01-28

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.21.0...0.22.0)

- Add `network-policy-allow-acm` to allow ACM traffic from ingress controller

## [0.21.0] - 2025-01-28

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.20.1...0.21.0)

- Upgrade module `terraform-google-gcp-mysql-db-and-user-creation-helper` to `0.4.0` with support for MySQL minor version selection.

## [0.20.1] - 2025-01-10

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.20.0...0.20.1)

- Fix NetworkPolicy configuration to guarantee that there is only one NetworkPolicy type per namespace.
- Fix NetworkPolicy deployment when you use an existing namespace.

## [0.20.0] - 2024-12-19

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.19.0...0.20.0)

- Add feature to enable network policy between `isolated` and `restricted` at namespace level.

## [0.19.0] - 2024-12-3

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.18.0...0.19.0)

- Refactor of `drupal_apps_all_data` to handle multiple deployment in same `project_name - project-id - release-branch-name`

## [0.18.0] - 2024-11-29

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.17.1...0.18.0)

- Add more complete outputs.

## [0.17.1] - 2024-11-27

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.17.0...0.17.1)

- Update default `bucket_soft_delete_retention_seconds` value (from 604800 seconds to 0 ) to disable soft retention

## [0.17.0] - 2024-11-26

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.16.0...0.17.0)

- Update module `terraform-google-gcp-application-bucket-creation-helper` to `0.10.0` with lifecycle policy for buckets.
- Update terraform docs docker image version using renovate.

## [0.16.0] - 2024-11-25

- Update module `terraform-google-gcp-application-bucket-creation-helper` to `0.9.0` with lifecycle policy for buckets.

## [0.15.0] - 2024-11-14

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.14.0...0.15.0)

### Added

- ⚠️ **BREAKING CHANGES**:
  - The cloudsql dump bucket has a new lifecycle policy. After 180 days the files are moved from `NEARLINE` to `COLDLINE`. After 360 days they will be deleted.

## [0.14.0] - 2024-11-06

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.13.0...0.14.0)

### Added

- Add support to customize the default labels of Kubernetes resources created by this module.

## [0.13.0] - 2024-11-05

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.12.1...0.13.0)

### Added

- Add support for Kubernetes namespace labels in the Drupal projects configuration.

### Removed

- ⚠️ **BREAKING CHANGES**:
  - we have removed the `lifecycle.ignore_changes` block from the `kubernetes_namespace` resource configuration. External modifications on namespace labels will now cause drift in the configuration. Ensure all necessary labels are defined in Terraform to avoid unexpected updates.
  - We have removed the helm values outputs.

## [0.12.1] - 2024-10-30

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.12.0...0.12.1)

- Update module `terraform-google-gcp-application-bucket-creation-helper` to `0.8.1` with fix compatibility between tags and random suffix in resource creation.
- Update module `terraform-google-gcp-mysql-db-and-user-creation-helper` to `0.3.2` with fix to accidental mysql credential exposure.
- Changed `drupal_projects_list.project_name` max lenght to 16 database creation is handled by the module itself.

## [0.12.0] - 2024-08-08

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.11.1...0.11.2)

- Update module `terraform-google-gcp-application-bucket-creation-helper` to `0.8.0` with support to finetune the soft_delete_retention policy of the buckets.

## [0.11.1] - 2024-08-08

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.11.0...0.11.1)

- Fix `drupal_buckets_names_list` output

## [0.11.0] - 2024-08-07

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.10.0...0.11.0)

- Added an output with the list of bucket names generated by the module.
- Added an output with the cloudsql dumps bucket name generated by the module.

## [0.10.0] - 2024-08-05

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.9.0...0.10.0)

- Added an option to create the bucket to use for all CloudSQL dumps for the given instance.

## [0.9.0] - 2024-02-08

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.8.1...0.9.0)

- Added an option to exclude the creation of the Kubernetes namespaces.

## [0.8.1] - 2023-08-09

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.8.0...0.8.1)

- Upgrade module `terraform-google-gcp-application-bucket-creation-helper` to version `0.7.1`.

## [0.8.0] - 2023-08-08

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.7.0...0.8.0)

- Add support for `bucket_obj_vwr` and `bucket_obj_adm` to set punctual permissions on the bucket.
- Add support for global tags to be passed to buckets.
- Upgraded module `terraform-google-gcp-application-bucket-creation-helper` to version `0.7.0`.

## [0.7.0] - 2023-07-27

[Compare with previous version](https://www.github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.6.0...0.7.0)

- Add support for bucket labels and Google tags. Upgraded module `terraform-google-gcp-application-bucket-creation-helper` to version `0.5.0`.

## [0.6.0] - 2023-07-18

[Compare with previous version](https://www.github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.5.1...0.6.0)

- **BREAKING CHANGE**: Upgrade module `terraform-google-gcp-application-bucket-creation-helper` to version `0.4.0`. By default, the `allUsers` permission is `roles/storage.legacyObjectReader`.

## [0.5.1] - 2023-07-05

[Compare with previous version](https://www.github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.5.0...0.5.1)

- Fix local with old `bucket_public_files_path` name.

## [0.5.0] - 2023-07-04

[Compare with previous version](https://www.github.com/sparkfabrik/terraform-google-gcp-cloud-native-drupal-resources/compare/0.4.0...0.5.0)

- **BREAKING CHANGE**: we renamed the `bucket_public_files_path` to `bucket_legacy_public_files_path` because in future versions of the module it will be deprecated and removed, as the value will have to be specified at the application level and not at infrastructure level. In addition, now the value must be an absolute path and no more relative as before, that is, it **must begin with a /**.

## [0.4.0] - 2023-06-26

- The path of Drupal public files in the bucket is now customizable

## [0.3.1] - 2023-05-29

- Ignore namespace labels from terraform state.

## [0.3.0] - 2023-05-24

- Upgrade module `terraform-google-gcp-application-bucket-creation-helper` to version `0.3.0`.
- Add `disaster_recovery_bucket_location` variable.

## [0.2.0] - 2023-04-13

### Changed

- Bump to 0.2, since 0.1 was a breaking change.
- Namespace creation on a kubernetes cluster.
- Database and user creation is now optional.
- Bucket creation is now optional.

## [0.1.0] - 2023-02-20

- First release.
