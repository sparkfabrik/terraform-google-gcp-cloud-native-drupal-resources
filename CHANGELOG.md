# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

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
