#!/bin/bash

# ~/iN/tools/clear-single-secret-from-cloudflare.sh

echo "Clearing individual secrets from Cloudflare..."

# 检查是否定义了 SECRET_STORE_ID 和要删除的 SECRET_ID
if [ -z "$CLOUDFLARE_SECRET_STORE_ID" ]; then
    echo "CLOUDFLARE_SECRET_STORE_ID is not defined in .env.secrets"
    exit 1
fi

if [ -z "$1" ]; then
    echo "You must provide the secret name to delete (e.g., RUNTIME_UNSPLASH_ACCESS_KEY)."
    exit 1
fi

SECRET_NAME=$1

# 获取机密的 Secret ID（需要手动配置，或通过某种方式获取）
SECRET_ID=$(npx wrangler secrets-store secret get "$CLOUDFLARE_SECRET_STORE_ID" --secret-name "$SECRET_NAME" --remote | grep "ID" | awk '{print $2}')

if [ -z "$SECRET_ID" ]; then
    echo "Secret with name $SECRET_NAME not found in Secrets Store."
    exit 1
fi

# 删除指定的单个机密
echo "Deleting secret: $SECRET_NAME with ID: $SECRET_ID..."
npx wrangler secrets-store secret delete "$CLOUDFLARE_SECRET_STORE_ID" --secret-id "$SECRET_ID" --remote

if [ $? -eq 0 ]; then
    echo "Secret $SECRET_NAME has been successfully deleted from Cloudflare."
else
    echo "Failed to delete secret $SECRET_NAME from Cloudflare."
    exit 1
fi
