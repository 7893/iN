#!/bin/bash

# ~/iN/tools/sync-runtime-to-cloudflare.sh
# 将 .env.secrets 中的非 Cloudflare 变量上传到指定 Secrets Store

if [[ ! -f ~/iN/.env.secrets ]]; then
    echo "❌ .env.secrets 文件不存在！"
    exit 1
fi

source ~/iN/.env.secrets

STORE_ID="$CLOUDFLARE_SECRET_STORE_ID"
if [[ -z "$STORE_ID" ]]; then
    echo "❌ CLOUDFLARE_SECRET_STORE_ID 未设置。"
    exit 1
fi

echo "🔐 正在上传 secrets 到 Cloudflare Secrets Store：$STORE_ID"

while IFS='=' read -r key value; do
    if [[ -z "$key" || "$key" =~ ^# || "$key" =~ ^CLOUDFLARE_ || "$key" == "STORE_ID" ]]; then
        continue
    fi

    if [[ -z "$value" ]]; then
        echo "⏭️  跳过空值变量：$key"
        continue
    fi

    echo "🧹 尝试先删除已存在的 $key（如果存在）..."
    existing_secrets=$(wrangler secrets-store secret list "$STORE_ID" --remote 2>/dev/null)
    secret_id=$(echo "$existing_secrets" | grep "$key" | awk -F '│' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}')
    if [[ -n "$secret_id" ]]; then
        wrangler secrets-store secret delete "$STORE_ID" --secret-id "$secret_id" --remote >/dev/null 2>&1
        echo "✅ 已删除 $key (ID: $secret_id)"
    fi

    echo "📤 创建新 secret：$key"
    wrangler secrets-store secret create "$STORE_ID" --name "$key" --value "$value" --scopes workers --remote

    if [[ $? -eq 0 ]]; then
        echo "✅ $key 上传成功"
    else
        echo "❌ $key 上传失败"
    fi
done < <(grep -E '^[A-Z0-9_]+=' ~/iN/.env.secrets)

echo "🎉 所有 secrets 已同步完成！"
