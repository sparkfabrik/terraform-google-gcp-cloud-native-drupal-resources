#!/usr/bin/env bash

# To get all buckets in your GCP project:
# gcloud storage ls --project=<GCP Project ID>

DRY_RUN=${DRY_RUN:-0}

BASEDIR=$(dirname "${0}")
NOT_PROCESSED_BUCKETS_FILE="${BASEDIR}/not-processed-buckets.txt"

BUCKETS="put-here-the-first-bucket \
put-here-the-second-bucket"

echo -n "" >"${NOT_PROCESSED_BUCKETS_FILE}"
for BUCKET in ${BUCKETS}; do
  echo "Check for bucket '${BUCKET}'"
  if ! gsutil ls -d "gs://${BUCKET}/public" >/dev/null 2>&1 || ! gsutil ls -d "gs://${BUCKET}/private" >/dev/null 2>&1; then
    echo "Bucket '${BUCKET}' not processed"
    echo "${BUCKET}" >>"${NOT_PROCESSED_BUCKETS_FILE}"
    continue
  fi

  echo "Bucket '${BUCKET}' has public and private folders. Setting ACLs..."
  if [ "${DRY_RUN}" -ne "0" ]; then
    echo "Exec the dry run commands..."
    echo "DRY RUN: gsutil -m acl set private gs://${BUCKET}/public/*"
    echo "DRY RUN: gsutil -m acl set -r public-read gs://${BUCKET}/public/"
    echo "DRY RUN: gsutil -m acl set -r private gs://${BUCKET}/private/"
    echo "End of dry run commands."
    continue
  fi

  echo "Exec the real commands..."
  # This gsutil command is useful to set the private ACL to the root level objects.
  gsutil -m acl set private "gs://${BUCKET}/public/*"
  # Set public-read ACL to all objects inside the public folder.
  gsutil -m acl set -r public-read "gs://${BUCKET}/public/"
  # Set private ACL to all objects inside the private folder.
  gsutil -m acl set -r private "gs://${BUCKET}/private/"
  echo "Bucket '${BUCKET}' processed."
done
