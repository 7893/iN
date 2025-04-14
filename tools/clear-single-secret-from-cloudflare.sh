#!/bin/bash

# ~/iN/tools/clear-single-secret-from-cloudflare.sh
# This script clears all secrets within a specific Cloudflare Secrets Store without deleting the store itself.

# Ensure .env.secrets exists
if [[ ! -f ~/iN/.env.secrets ]]; then
    echo ".env.secrets file not found!"
    exit 1
fi

# Load the secrets from .env.secrets
source ~/iN/.env.secrets

# Ensure CLOUDFLARE_SECRET_STORE_ID is set in .env.secrets
if [[ -z "$CLOUDFLARE_SECRET_STORE_ID" ]]; then
    echo "CLOUDFLARE_SECRET_STORE_ID is not set in .env.secrets"
    exit 1
fi

echo "Clearing individual secrets from Cloudflare..."

# List all secrets in the store and extract both secret names and IDs
secrets=$(npx wrangler secrets-store secret list $CLOUDFLARE_SECRET_STORE_ID --remote | \
          sed '1d' | \
          awk '{print $1, $2}' | \
          grep -vE '^-+$' | \
          grep -vE '^ID$')

# Loop through each secret name and ID to delete it
while IFS= read -r line; do
    secret_name=$(echo $line | awk '{print $1}')
    secret_id=$(echo $line | awk '{print $2}')

    echo "Clearing secret: $secret_name with ID: $secret_id from Cloudflare..."

    # Delete each secret using its ID
    npx wrangler secrets-store secret delete $CLOUDFLARE_SECRET_STORE_ID --secret-id "$secret_id" --remote

    if [[ $? -eq 0 ]]; then
        echo "$secret_name cleared successfully from Cloudflare."
    else
        echo "Failed to clear $secret_name from Cloudflare."
    fi
done <<< "$secrets"

echo "Cloudflare secret clear complete!"
