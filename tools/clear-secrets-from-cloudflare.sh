#!/bin/bash

# ~/iN/tools/clear-secrets-from-cloudflare.sh

echo "Clearing Cloudflare Secrets Store..."

# 检查是否定义了 SECRET_STORE_ID
if [ -z "$CLOUDFLARE_SECRET_STORE_ID" ]; then
    echo "CLOUDFLARE_SECRET_STORE_ID is not defined in .env.secrets"
    exit 1
fi

# 删除 Secrets Store
echo "Deleting the entire Secrets Store with ID: $CLOUDFLARE_SECRET_STORE_ID..."
npx wrangler secrets-store store delete "$CLOUDFLARE_SECRET_STORE_ID" --remote

if [ $? -eq 0 ]; then
    echo "Secrets Store with ID $CLOUDFLARE_SECRET_STORE_ID has been successfully deleted from Cloudflare."
else
    echo "Failed to delete Secrets Store with ID $CLOUDFLARE_SECRET_STORE_ID."
    exit 1
fi
