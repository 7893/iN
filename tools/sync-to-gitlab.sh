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

# 从文件中加载 GitLab 相关变量（比如 GITLAB_PAT 和 GITLAB_PROJECT_ID），其他变量将通过逐行解析获取
# 注意：文件中的格式要求每一行为 KEY=VALUE（不要多余的空格或引号）
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

# 过滤规则：只同步 .env.secrets 文件中写明的变量，不处理那些不需要同步的变量
# 我们根据变量名过滤掉以 CLOUDFLARE_ 开头的（比如 CLOUDFLARE_ACCOUNT_ID、CLOUDFLARE_API_TOKEN、CLOUDFLARE_R2_API_TOKEN、CLOUDFLARE_SECRET_STORE_ID）
# 以及 GitLab 自身的敏感变量 GITLAB_PAT（其它的比如 GITLAB_PROJECT_ID/GITLAB_PROJECT_NAME/GITLAB_OWNER 是项目相关的，但这里我们也统一按照需求同步，如果不需要可自行过滤）
# 脚本采用直接从文件中按行读取的方式，避免环境污染

while IFS= read -r line || [[ -n "$line" ]]; do
  # 忽略以 # 开头的注释行和空行
  if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
    continue
  fi

  # 解析行内容，拆分成 key 和 value（仅用第一个 = 作为分隔符）
  key=$(echo "$line" | cut -d '=' -f 1)
  value=$(echo "$line" | cut -d '=' -f 2-)

  # 去除 value 前后可能的空格以及引号
  value=$(echo "$value" | sed 's/^[ \t]*//;s/[ \t]*$//;s/^"//;s/"$//')

  # 如果该变量是不需要同步到 GitLab 的（比如以 CLOUDFLARE_ 开头，或者是 GITLAB_PAT），则跳过
  if [[ "$key" =~ ^CLOUDFLARE_ ]] || [[ "$key" == "GITLAB_PAT" ]]; then
    echo "⏭️  跳过 $key (不需要上传到 GitLab)"
    continue
  fi

  # 跳过空值
  if [[ -z "$value" ]]; then
    echo "⚠️  跳过 $key (值为空)"
    continue
  fi

  echo "🔍 检查 $key 是否存在于 GitLab..."
  # 先通过 GET 请求检查变量是否存在
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
