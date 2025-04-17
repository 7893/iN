#!/bin/bash

# ~/iN/tools/clear-single-secret-from-cloudflare.sh
# 清空指定 Cloudflare Secrets Store 中的所有 secrets（保留 store）

# === 加载 .env.secrets ===
if [[ ! -f ~/iN/.env.secrets ]]; then
    echo "❌ Error: .env.secrets 文件不存在！"
    exit 1
fi
source ~/iN/.env.secrets

if [[ -z "$CLOUDFLARE_SECRET_STORE_ID" ]]; then
    echo "❌ Error: CLOUDFLARE_SECRET_STORE_ID 未设置。"
    exit 1
fi

echo "✅ 使用的 Secrets Store ID：$CLOUDFLARE_SECRET_STORE_ID"
echo "🚀 正在尝试清空该 Secrets Store 中的所有 secret..."

# === 获取 wrangler 输出 ===
secrets_output=$(wrangler secrets-store secret list "$CLOUDFLARE_SECRET_STORE_ID" --remote 2>&1)

if [[ $? -ne 0 ]]; then
    echo "❌ 获取 secrets 列表失败。Wrangler 输出："
    echo "$secrets_output"
    exit 1
fi

# === 提取 secret name 和 id ===
secrets_parsed=$(echo "$secrets_output" |
    grep -E '[│┃]' |
    grep -E '[0-9a-f]{32}' |
    awk -F '│' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); gsub(/^[ \t]+|[ \t]+$/, "", $3); if ($2 && $3) print $2, $3}')

if [[ -z "$secrets_parsed" ]]; then
    echo "✅ 该 Secrets Store 中没有需要删除的 secret。"
    exit 0
fi

echo "🔐 找到以下 secrets："
echo "$secrets_parsed"
echo

# === 删除每个 secret ===
while IFS= read -r line; do
    secret_name=$(echo "$line" | awk '{print $1}')
    secret_id=$(echo "$line" | awk '{print $2}')

    echo "🗑️  正在删除：$secret_name (ID: $secret_id)..."

    delete_output=$(wrangler secrets-store secret delete "$CLOUDFLARE_SECRET_STORE_ID" --secret-id "$secret_id" --remote 2>&1)

    if [[ $? -eq 0 ]]; then
        echo "✅ 已删除 $secret_name"
    else
        echo "❌ 删除 $secret_name 失败："
        echo "$delete_output"
    fi

    echo
done <<< "$secrets_parsed"

echo "🎉 所有 secret 删除操作完成！"
