additionalEnvs:
  - name: PKG_DRUPAL_OSB_HOST
    valueFrom:
      secretKeyRef:
        name: ${secret_bucket_name}
        key: endpoint
  - name: PKG_DRUPAL_OSB_BUCKET_NAME
    valueFrom:
      secretKeyRef:
        name: ${secret_bucket_name}
        key: name
  - name: PKG_DRUPAL_OSB_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: ${secret_bucket_name}
        key: username
  - name: PKG_DRUPAL_OSB_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: ${secret_bucket_name}
        key: password
