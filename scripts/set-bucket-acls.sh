#!/usr/bin/env bash

# To get all buckets in your GCP project:
# gcloud storage ls --project=<GCP Project ID>

DRY_RUN=${DRY_RUN:-0}

BASEDIR=$(dirname "$0")
NOT_PROCESSED_BUCKETS_FILE="${BASEDIR}/not-processed-buckets.txt"

BUCKETS="put-here-the-first-bucket put-here-the-second-bucket"

: >"$NOT_PROCESSED_BUCKETS_FILE"

for BUCKET in $BUCKETS; do
  echo "Check for bucket '${BUCKET}'"
  if ! gcloud storage ls "gs://${BUCKET}/public/" >/dev/null 2>&1 ||
    ! gcloud storage ls "gs://${BUCKET}/private/" >/dev/null 2>&1; then
    echo "Bucket '${BUCKET}' not processed"
    echo "${BUCKET}" >>"$NOT_PROCESSED_BUCKETS_FILE"
    continue
  fi

  echo "Bucket '${BUCKET}' has public and private folders. Setting ACLs..."
  if [[ "$DRY_RUN" -ne 0 ]]; then
    echo "DRY RUN: gcloud storage objects update --recursive --predefined-acl=private gs://${BUCKET}/*"
    echo "DRY RUN: gcloud storage objects update --recursive --predefined-acl=publicRead gs://${BUCKET}/public/**"
    echo "DRY RUN: gcloud storage objects update --recursive --predefined-acl=private gs://${BUCKET}/private/**"
    continue
  fi

  gcloud storage objects update --recursive --predefined-acl=private "gs://${BUCKET}/*"
  gcloud storage objects update --recursive --predefined-acl=publicRead "gs://${BUCKET}/public/**"
  gcloud storage objects update --recursive --predefined-acl=private "gs://${BUCKET}/private/**"
  echo "Bucket '${BUCKET}' processed."
done
