#!/bin/bash

# ~/iN/tools/sync-runtime-to-cloudflare.sh
# This script syncs necessary runtime secrets to Cloudflare's Secrets Store

# Ensure .env.secrets exists
if [[ ! -f ~/iN/.env.secrets ]]; then
    echo ".env.secrets file not found!"
    exit 1
fi

# Load the secrets from .env.secrets
source ~/iN/.env.secrets

# Cloudflare account and API tokens should not be uploaded again to Cloudflare
# Define the runtime secrets to sync (excluding Cloudflare and GitLab secrets)
cf_secrets=(
  "RUNTIME_UNSPLASH_ACCESS_KEY"
  "RUNTIME_R2_S3_ACCESS_KEY_ID"
  "RUNTIME_R2_S3_SECRET_ACCESS_KEY"
  "RUNTIME_HMAC_SECRET"
  "RUNTIME_EXTERNAL_AI_API_KEY"
  "RUNTIME_R2_S3_ENDPOINT_DEFAULT"
  "RUNTIME_R2_S3_ENDPOINT_EU"
  "AXIOM_API_TOKEN"
)

# Define Cloudflare Secrets Store ID
STORE_ID=$CLOUDFLARE_SECRET_STORE_ID

# Check if the CLOUDFLARE_SECRET_STORE_ID is set
if [[ -z "$STORE_ID" ]]; then
    echo "CLOUDFLARE_SECRET_STORE_ID is not defined in .env.secrets!"
    exit 1
fi

echo "Syncing runtime secrets to Cloudflare..."

# Loop through the secrets and upload them to Cloudflare Secrets Store
for secret in "${cf_secrets[@]}"; do
    value="${!secret}"
    if [[ -z "$value" ]]; then
        echo "Skipping empty secret: $secret"
        continue
    fi

    # Upload each secret to Cloudflare
    echo "Syncing $secret to Cloudflare..."
    npx wrangler secrets-store secret create $STORE_ID --name $secret --value "$value" --scopes workers --remote

    if [[ $? -eq 0 ]]; then
        echo "$secret synced successfully to Cloudflare."
    else
        echo "Failed to sync $secret to Cloudflare."
    fi
done

echo "Cloudflare secret sync complete!"

