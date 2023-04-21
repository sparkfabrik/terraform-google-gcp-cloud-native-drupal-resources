additionalEnvs:
  - name: DB_HOST_0
    valueFrom:
      secretKeyRef:
        name: ${database_secret_name}
        key: endpoint
  - name: DB_USER_0
    valueFrom:
      secretKeyRef:
        name: ${database_secret_name}
        key: username
  - name: DB_PASS_0
    valueFrom:
      secretKeyRef:
        name: ${database_secret_name}
        key: password
  - name: DB_PORT_0
    valueFrom:
      secretKeyRef:
        name: ${database_secret_name}
        key: port
  - name: DB_NAME_0
    valueFrom:
      secretKeyRef:
        name: ${database_secret_name}
        key: database
