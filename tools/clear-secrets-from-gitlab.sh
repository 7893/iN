#!/bin/bash

# ~/iN/tools/clear-all-secrets-from-gitlab.sh
# 清空 GitLab 项目中所有 CI/CD 环境变量（慎用！）

SECRETS_FILE="$HOME/iN/.env.secrets"

if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "❌ .env.secrets 文件不存在: $SECRETS_FILE"
  exit 1
fi

source "$SECRETS_FILE"

if [[ -z "$GITLAB_PROJECT_ID" || -z "$GITLAB_PAT" ]]; then
  echo "❌ GITLAB_PROJECT_ID 或 GITLAB_PAT 未在 .env.secrets 中设置"
  exit 1
fi

GITLAB_API_URL="https://gitlab.com/api/v4"

echo "🚨 即将清除 GitLab 项目 ID: $GITLAB_PROJECT_ID 的所有 CI/CD 环境变量..."
echo "⚠️  本操作不可撤销，是否继续？[y/N]"
read -r confirm
if [[ "$confirm" != "y" ]]; then
  echo "❎ 已取消"
  exit 0
fi

# 获取所有变量名
echo "📥 获取 GitLab 当前环境变量列表..."
all_keys=$(curl -sS --header "PRIVATE-TOKEN: $GITLAB_PAT" \
  "$GITLAB_API_URL/projects/$GITLAB_PROJECT_ID/variables" | jq -r '.[].key')

if [[ -z "$all_keys" ]]; then
  echo "✅ 没有找到需要删除的变量。"
  exit 0
fi

# 遍历并删除
for key in $all_keys; do
  echo "🗑️  删除 $key..."
  curl -sS --request DELETE \
       --header "PRIVATE-TOKEN: $GITLAB_PAT" \
       "$GITLAB_API_URL/projects/$GITLAB_PROJECT_ID/variables/$key"

  if [[ $? -eq 0 ]]; then
    echo "✅ $key 已删除"
  else
    echo "❌ 删除 $key 失败"
  fi
done

echo "🎉 GitLab CI/CD 变量已全部清除！"
