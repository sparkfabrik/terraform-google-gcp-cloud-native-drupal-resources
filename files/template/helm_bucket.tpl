additionalEnvs:
  - name: OSB_HOST
    valueFrom:
      secretKeyRef:
        name: ${bucket_secret_name}
        key: endpoint
  - name: OSB_BUCKET
    valueFrom:
      secretKeyRef:
        name: ${bucket_secret_name}
        key: name
  - name: OSB_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: ${bucket_secret_name}
        key: username
  - name: OSB_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: ${bucket_secret_name}
        key: password
  - name: NGINX_OSB_BUCKET
    valueFrom:
      secretKeyRef:
        name: ${bucket_secret_name}
        key: nginx_osb_bucket
