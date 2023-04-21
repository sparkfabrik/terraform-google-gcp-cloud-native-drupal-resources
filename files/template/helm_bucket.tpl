additionalEnvs:
  - name: OSB_HOST
    valueFrom:
      secretKeyRef:
        name: ${secret_bucket_name}
        key: endpoint
  - name: OSB_BUCKET
    valueFrom:
      secretKeyRef:
        name: ${secret_bucket_name}
        key: name
  - name: OSB_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: ${secret_bucket_name}
        key: username
  - name: OSB_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: ${secret_bucket_name}
        key: password
  - name: NGINX_OSB_BUCKET
    valueFrom:
      secretKeyRef:
        name: ${secret_bucket_name}
        key: nginx_osb_bucket
