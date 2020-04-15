   docker run --cap-add=IPC_LOCK -d \
       -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' \
       -p 8200:8200 \
       hashicorp/vault:latest \
       server -dev

export VAULT_TOKEN=myroot