#!/bin/bash

# ~/iN/tools/sync-to-gitlab.sh
# 同步 .env.secrets 文件中定义的环境变量到 GitLab CI/CD 项目变量
# 注意：本脚本只处理 .env.secrets 文件中明文写的行，不会加载 shell 中已有的全部变量。

# 定义 .env.secrets 文件的绝对路径
SECRETS_FILE="$HOME/iN/.env.secrets"

if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "❌ .env.secrets 文件不存在: $SECRETS_FILE"
  exit 1
fi

# 加载 GitLab PAT 和 Project ID（只这两个变量通过 source 引入，其余逐行读取）
source "$SECRETS_FILE"

# 检查必须的 GitLab 变量
if [[ -z "$GITLAB_PROJECT_ID" ]]; then
  echo "❌ 未在 .env.secrets 中定义 GITLAB_PROJECT_ID"
  exit 1
fi

if [[ -z "$GITLAB_PAT" ]]; then
  echo "❌ 未在 .env.secrets 中定义 GITLAB_PAT"
  exit 1
fi

GITLAB_API_URL="https://gitlab.com/api/v4"
echo "🚀 从 .env.secrets 同步变量到 GitLab 项目 ID: $GITLAB_PROJECT_ID"

while IFS= read -r line || [[ -n "$line" ]]; do
  # 忽略注释和空行
  if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
    continue
  fi

  # 拆分 key 和 value
  key=$(echo "$line" | cut -d '=' -f 1)
  value=$(echo "$line" | cut -d '=' -f 2-)

  # 去除 value 前后空格和引号
  value=$(echo "$value" | sed 's/^[ \t]*//;s/[ \t]*$//;s/^"//;s/"$//')

  # 过滤不上传的变量：仅跳过以 CLOUDFLARE_ 开头或是 GITLAB_PAT 本身
  if [[ "$key" =~ ^CLOUDFLARE_ ]] || [[ "$key" == "GITLAB_PAT" ]]; then
    echo "⏭️  跳过 $key (不需要上传到 GitLab)"
    continue
  fi

  # 跳过值为空的变量
  if [[ -z "$value" ]]; then
    echo "⚠️  跳过 $key (值为空)"
    continue
  fi

  echo "📝 正在处理 $key=$value"
  echo "🔍 检查 $key 是否存在于 GitLab..."

  # 检查变量是否已存在
  existing=$(curl -sS --header "PRIVATE-TOKEN: $GITLAB_PAT" \
    "$GITLAB_API_URL/projects/$GITLAB_PROJECT_ID/variables/$key" | jq -r '.key // empty')

  if [[ "$existing" == "$key" ]]; then
    echo "🔄 更新 $key..."
    curl -sS --request PUT "$GITLAB_API_URL/projects/$GITLAB_PROJECT_ID/variables/$key" \
      --header "PRIVATE-TOKEN: $GITLAB_PAT" \
      --header "Content-Type: application/json" \
      --data "{\"value\": \"$value\", \"masked\": true, \"protected\": false, \"environment_scope\": \"*\"}" > /dev/null
    echo "✅ $key 已更新"
  else
    echo "➕ 创建 $key..."
    curl -sS --request POST "$GITLAB_API_URL/projects/$GITLAB_PROJECT_ID/variables" \
      --header "PRIVATE-TOKEN: $GITLAB_PAT" \
      --header "Content-Type: application/json" \
      --data "{\"key\": \"$key\", \"value\": \"$value\", \"masked\": true, \"protected\": false, \"environment_scope\": \"*\"}" > /dev/null
    echo "✅ $key 已创建"
  fi
done < "$SECRETS_FILE"

echo "🎉 GitLab 变量同步完成！"
