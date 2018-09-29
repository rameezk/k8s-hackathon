kubectl create secret generic kibana-oauth-secrets \
  -o yaml --dry-run \
  -n logging \
  --from-literal=client-id=c380837ab64d47d5e09b \
  --from-literal=client-secret=6da70afc57b73560c5388f7aa2435b6fc722e2be \
  --from-literal=cookie=$(python -c 'import os,base64; print base64.urlsafe_b64encode(os.urandom(16))') >> templates/secret.yaml