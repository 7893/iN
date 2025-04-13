#!/bin/bash
# sync-to-gitlab.sh
# 读取 .env.secrets 文件并将所有非注释的环境变量同步到 GitLab CI/CD Variables
# (包括 RUNTIME_* 变量，以便 CI/CD 流水线可以读取它们并推送到 Cloudflare)
#
# 前提条件:
# 1. 设置了环境变量 GITLAB_PAT，包含有效的 GitLab 个人访问令牌 (具有 api 权限)。
#    (脚本将从此环境变量读取令牌)
# 2. 确保 curl 工具已安装。

# 配置 GitLab 项目信息
GITLAB_API="https://gitlab.com/api/v4"
PROJECT_ID="68866224" # 替换为你的 GitLab 项目 ID

# 检查 GITLAB_PAT 是否设置 (使用 .env.secrets 中定义的名称)
if [ -z "$GITLAB_PAT" ]; then
  echo "错误: 环境变量 GITLAB_PAT 未设置。请确保已通过 .bashrc 或其他方式从 .env.secrets 加载。"
  exit 1
fi

# 本地 .env.secrets 路径 (使用 $HOME 提高可靠性)
ENV_FILE_PATH="$HOME/iN/.env.secrets"

# 检查 .env.secrets 文件是否存在
if [ ! -f "$ENV_FILE_PATH" ]; then
  echo "错误: secrets 文件未找到: $ENV_FILE_PATH"
  exit 1
fi

echo "开始同步所有非注释变量到 GitLab 项目 $PROJECT_ID 的 CI/CD Variables..."

# 读取文件中的每一行
while IFS='=' read -r key value || [[ -n "$key" ]]; do
  # 去除可能存在的回车符 (CR) - 增强跨平台兼容性
  value=$(echo "$value" | tr -d '\r')
  key=$(echo "$key" | tr -d '\r')

  # 忽略注释行和空 key
  if [[ ! "$key" =~ ^#.* && -n "$key" ]]; then
    echo "正在设置/更新 GitLab CI/CD 变量: $key ..."

    # 使用 curl 调用 GitLab API
    # 使用 PUT /projects/:id/variables/:key 来实现幂等性 (创建或更新)
    # 注意：这里改为使用 PUT 方法，需要对 key 进行 URL 编码
    key_encoded=$(printf %s "$key" | jq -s -R -r @uri) # 需要安装 jq 工具进行 URL 编码

    # 检查是否安装了 jq
    if ! command -v jq &> /dev/null; then
        echo "错误: 需要 jq 工具来进行 URL 编码。请安装 jq (例如: sudo apt-get install jq)。"
        # 或者使用其他 URL 编码方法
        # key_encoded=$(python3 -c 'import urllib.parse; print(urllib.parse.quote(input()))' <<< "$key") # Python 方式
        # 如果没有 jq 或 python，回退到 POST，但不保证幂等性
         echo "警告: 未找到 jq 或 python3 进行 URL 编码，回退到使用 POST 方法 (可能创建重复变量)。"
         http_status=$(curl -s -w "%{http_code}" -o /dev/null \
           --request POST \
           --header "PRIVATE-TOKEN: $GITLAB_PAT" \
           --form "key=$key" \
           --form "value=$value" \
           --form "masked=true" \
           --form "variable_type=env_var" \
           "$GITLAB_API/projects/$PROJECT_ID/variables")
    else
        # 使用 PUT 方法进行创建或更新
        http_status=$(curl -s -w "%{http_code}" -o /dev/null \
          --request PUT \
          --header "PRIVATE-TOKEN: $GITLAB_PAT" \
          --header "Content-Type: application/json" \
          --data "{\"value\": \"$value\", \"masked\": true, \"protected\": false, \"variable_type\": \"env_var\"}" \
          "$GITLAB_API/projects/$PROJECT_ID/variables/$key_encoded") # 使用 URL 编码后的 key
    fi


    # 检查 HTTP 状态码
    if [[ "$http_status" -eq 200 || "$http_status" -eq 201 ]]; then # 200 OK (更新), 201 Created
      echo "成功设置/更新 $key."
    else
      echo "错误: 设置/更新 $key 失败。HTTP 状态码: $http_status"
      echo "请检查 GitLab 令牌 ($GITLAB_PAT) 权限、项目 ID ($PROJECT_ID) 或变量值是否符合 GitLab 要求 (特别是 masking，不是所有值都能被 mask)。"
      # exit 1 # 根据需要决定是否在出错时退出
    fi
  fi
done < "$ENV_FILE_PATH"

echo "GitLab CI/CD 变量同步完成。"